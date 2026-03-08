defmodule UniboV4.Marketing.Workflows.EventRegistration.EventRegistrationLifecycleWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  支持分支路由、失败回退、重试与幂等扩展钩子。
  """

  alias UniboV4.Marketing.EventRegistration

  def steps do
    [:create, :confirm, :set_done, :cancel, :set_previous_state, :send_badge_email]
  end

  @workflow_semantics_json ~S"""
{"steps":[{"idempotency_key":null,"next":["confirm","cancel"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"create"},{"idempotency_key":null,"next":["set_done","cancel","send_badge_email"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"confirm"},{"idempotency_key":null,"next":["cancel"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"set_done"},{"idempotency_key":null,"next":["set_previous_state"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"cancel"},{"idempotency_key":null,"next":["confirm"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"set_previous_state"},{"idempotency_key":null,"next":[],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"send_badge_email"}],"workflow":"event_registration_lifecycle"}
"""
  def workflow_semantics_json, do: String.trim(@workflow_semantics_json)

  def run(record, opts \\ []) do
    state = %{
      trace: [],
      cache: %{},
      attempts: %{},
      max_hops: Keyword.get(opts, :max_hops, 128)
    }

    run_step(record, List.first(steps()), state, opts)
  end

  defp run_step(record, nil, _state, _opts), do: {:ok, record}

  defp run_step(record, step, state, opts) do
    trace = [step | state.trace]

    if length(trace) > state.max_hops do
      {:error, %{step: step, reason: :max_hops_exceeded, trace: Enum.reverse(trace)}}
    else
      if step_skipped?(step, record) do
        run_step(record, choose_next_step(step, record), %{state | trace: trace}, opts)
      else
        case execute_step(record, step, opts, state) do
          {:ok, next_record, next_state} ->
            run_step(next_record, choose_next_step(step, next_record), %{next_state | trace: trace}, opts)

          {:error, reason, next_state} ->
            case choose_error_step(step) do
              nil ->
                {:error, %{step: step, reason: reason, trace: Enum.reverse(trace), attempts: Map.get(next_state.attempts, step, 1)}}

              error_step ->
                run_step(record, error_step, %{next_state | trace: [{:error, step, reason} | trace]}, opts)
            end
        end
      end
    end
  end

  defp execute_step(record, step, opts, state) do
    params_by_step = Keyword.get(opts, :params, %{})
    params = Map.get(params_by_step, step, %{})
    key = build_idempotency_key(step, record, params, opts)

    case fetch_idempotent_result(step, key, state, opts) do
      {:hit, cached_record, next_state} ->
        {:ok, cached_record, next_state}

      {:miss, next_state} ->
        execute_with_retry(record, step, params, opts, next_state, key)
    end
  end

  defp execute_with_retry(record, step, params, opts, state, key) do
    retry = retry_policy(step)
    max_attempts = max(1, Map.get(retry, :max_attempts, 1))
    backoff_ms = max(0, Map.get(retry, :backoff_ms, 0))
    do_execute_with_retry(record, step, params, opts, state, key, 1, max_attempts, backoff_ms)
  end

  defp do_execute_with_retry(record, step, params, opts, state, key, attempt, max_attempts, backoff_ms) do
    case apply_step(record, step, params, opts) do
      {:ok, next_record} ->
        next_state = state |> put_attempt(step, attempt) |> store_idempotent_result(step, key, next_record, opts)
        {:ok, next_record, next_state}

      {:error, reason} ->
        next_state = put_attempt(state, step, attempt)
        if attempt < max_attempts do
          maybe_sleep(backoff_ms)
          do_execute_with_retry(record, step, params, opts, next_state, key, attempt + 1, max_attempts, backoff_ms)
        else
          {:error, %{reason: reason, attempts: attempt}, next_state}
        end
    end
  end

  defp apply_step(record, step, params, opts) do
    actor = Keyword.get(opts, :actor)
    tenant = Keyword.get(opts, :tenant)
    ash_opts = [actor: actor] |> maybe_put_tenant(tenant)

    case step do
      :create ->
        Ash.create(Ash.Changeset.for_create(EventRegistration, :create, params), ash_opts)
      :confirm ->
        Ash.update(Ash.Changeset.for_update(record, :confirm, params), ash_opts)
      :set_done ->
        Ash.update(Ash.Changeset.for_update(record, :set_done, params), ash_opts)
      :cancel ->
        Ash.update(Ash.Changeset.for_update(record, :cancel, params), ash_opts)
      :set_previous_state ->
        Ash.update(Ash.Changeset.for_update(record, :set_previous_state, params), ash_opts)
      :send_badge_email ->
        Ash.update(Ash.Changeset.for_update(record, :send_badge_email, params), ash_opts)
      _ -> {:ok, record}
    end
  end

  defp choose_next_step(step, record) do
    case branch_next(step, record) do
      nil ->
        case next_candidates(step) do
          [next | _] -> next
          _ -> nil
        end
      next -> next
    end
  end

  defp choose_error_step(step) do
    case on_error_candidates(step) do
      [next | _] -> next
      _ -> nil
    end
  end

  defp next_candidates(step) do
    case step do
      :create -> [:confirm, :cancel]
      :confirm -> [:set_done, :cancel, :send_badge_email]
      :set_done -> [:cancel]
      :cancel -> [:set_previous_state]
      :set_previous_state -> [:confirm]
      :send_badge_email -> []
      _ -> []
    end
  end

  defp on_error_candidates(step) do
    case step do
      :create -> []
      :confirm -> []
      :set_done -> []
      :cancel -> []
      :set_previous_state -> []
      :send_badge_email -> []
      _ -> []
    end
  end

  defp branch_next(step, record) do
    case step do
      :create -> nil
      :confirm -> nil
      :set_done -> nil
      :cancel -> nil
      :set_previous_state -> nil
      :send_badge_email -> nil
      _ -> nil
    end
  end

  defp step_skipped?(step, record) do
    case step do
      :create -> false
      :confirm -> false
      :set_done -> false
      :cancel -> false
      :set_previous_state -> false
      :send_badge_email -> false
      _ -> false
    end
  end

  defp retry_policy(step) do
    case step do
      :create -> %{max_attempts: 1, backoff_ms: 0}
      :confirm -> %{max_attempts: 1, backoff_ms: 0}
      :set_done -> %{max_attempts: 1, backoff_ms: 0}
      :cancel -> %{max_attempts: 1, backoff_ms: 0}
      :set_previous_state -> %{max_attempts: 1, backoff_ms: 0}
      :send_badge_email -> %{max_attempts: 1, backoff_ms: 0}
      _ -> %{max_attempts: 1, backoff_ms: 0}
    end
  end

  defp step_idempotency_source(step) do
    case step do
      :create -> nil
      :confirm -> nil
      :set_done -> nil
      :cancel -> nil
      :set_previous_state -> nil
      :send_badge_email -> nil
      _ -> nil
    end
  end

  defp build_idempotency_key(step, record, params, opts) do
    source = step_idempotency_source(step)
    value =
      case source do
        nil ->
          Keyword.get(opts, :request_id) || map_get(params, :request_id) || map_get(params, "request_id") || map_get(record, :id) || map_get(record, "id") || "no_request_id"
        field ->
          map_get(params, field) || map_get(record, field) || keyword_get(opts, field) || field
      end

    "#{step}:#{value}"
  end

  defp fetch_idempotent_result(step, key, state, opts) do
    local_key = {step, key}
    cache = Map.get(state, :cache, %{})
    case Map.fetch(cache, local_key) do
      {:ok, cached} ->
        {:hit, cached, state}
      :error ->
        case Keyword.get(opts, :idempotency_get) do
          getter when is_function(getter, 2) ->
            case getter.(step, key) do
              {:ok, cached} ->
                next_state = Map.put(state, :cache, Map.put(cache, local_key, cached))
                {:hit, cached, next_state}
              _ -> {:miss, state}
            end
          _ -> {:miss, state}
        end
    end
  end

  defp store_idempotent_result(state, step, key, record, opts) do
    local_key = {step, key}
    cache = Map.get(state, :cache, %{})
    next_state = Map.put(state, :cache, Map.put(cache, local_key, record))

    case Keyword.get(opts, :idempotency_put) do
      setter when is_function(setter, 3) ->
        _ = setter.(step, key, record)
        next_state
      _ -> next_state
    end
  end

  defp put_attempt(state, step, attempt) do
    attempts = Map.get(state, :attempts, %{})
    Map.put(state, :attempts, Map.put(attempts, step, attempt))
  end

  defp map_get(map, key) when is_map(map) and is_atom(key) do
    Map.get(map, key) || Map.get(map, Atom.to_string(key))
  end

  defp map_get(map, key) when is_map(map) and is_binary(key) do
    Map.get(map, key) ||
      Enum.find_value(map, fn
        {k, v} when is_binary(k) and k == key -> v
        {k, v} when is_atom(k) ->
          if Atom.to_string(k) == key, do: v, else: nil
        _ -> nil
      end)
  end

  defp map_get(_, _), do: nil

  defp keyword_get(opts, key) when is_list(opts) and is_atom(key), do: Keyword.get(opts, key)
  defp keyword_get(opts, key) when is_list(opts) and is_binary(key) do
    Enum.find_value(opts, fn
      {k, v} when is_binary(k) and k == key -> v
      {k, v} when is_atom(k) ->
        if Atom.to_string(k) == key, do: v, else: nil
      _ -> nil
    end)
  end
  defp keyword_get(_, _), do: nil

  defp maybe_sleep(ms) when is_integer(ms) and ms > 0 do
    Process.sleep(ms)
  end
  defp maybe_sleep(_), do: :ok

  defp maybe_put_tenant(opts, nil), do: opts
  defp maybe_put_tenant(opts, tenant), do: Keyword.put(opts, :tenant, tenant)
end
