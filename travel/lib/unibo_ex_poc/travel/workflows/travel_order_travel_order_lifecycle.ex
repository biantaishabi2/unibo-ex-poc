defmodule UniboExPoc.Travel.Workflows.TravelOrder.TravelOrderLifecycleWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  支持分支路由、失败回退、重试与幂等扩展钩子。
  """

  alias UniboExPoc.Travel.TravelOrder

  def steps do
    [:create_order, :update, :confirm_quote, :submit_order, :submit_waitlist, :mark_payment_succeeded, :mark_booked, :fulfill_waitlist, :cancel_waitlist, :request_cancel, :approve_cancel, :request_change, :confirm_change, :mark_completed, :mark_order_failed, :destroy]
  end

  @workflow_semantics_json ~S"""
{"steps":[{"idempotency_key":null,"next":["update","confirm_quote","destroy"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"create_order"},{"idempotency_key":null,"next":["confirm_quote","destroy"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"update"},{"idempotency_key":null,"next":["submit_order","submit_waitlist"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"confirm_quote"},{"idempotency_key":null,"next":["mark_payment_succeeded","mark_order_failed"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"submit_order"},{"idempotency_key":null,"next":["mark_payment_succeeded","mark_order_failed"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"submit_waitlist"},{"idempotency_key":null,"next":["mark_booked","fulfill_waitlist","cancel_waitlist"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"mark_payment_succeeded"},{"idempotency_key":null,"next":["mark_completed","request_cancel","request_change"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"mark_booked"},{"idempotency_key":null,"next":["mark_completed","request_cancel","request_change"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"fulfill_waitlist"},{"idempotency_key":null,"next":["request_cancel"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"cancel_waitlist"},{"idempotency_key":null,"next":["approve_cancel"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"request_cancel"},{"idempotency_key":null,"next":["request_change"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"approve_cancel"},{"idempotency_key":null,"next":["confirm_change"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"request_change"},{"idempotency_key":null,"next":["mark_completed"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"confirm_change"},{"idempotency_key":null,"next":["mark_order_failed"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"mark_completed"},{"idempotency_key":null,"next":["destroy"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"mark_order_failed"},{"idempotency_key":null,"next":[],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"destroy"}],"workflow":"travel_order_lifecycle"}
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
      :create_order ->
        Ash.create(Ash.Changeset.for_create(TravelOrder, :create_order, params), ash_opts)
      :update ->
        Ash.update(Ash.Changeset.for_update(record, :update, params), ash_opts)
      :confirm_quote ->
        Ash.update(Ash.Changeset.for_update(record, :confirm_quote, params), ash_opts)
      :submit_order ->
        Ash.update(Ash.Changeset.for_update(record, :submit_order, params), ash_opts)
      :submit_waitlist ->
        Ash.update(Ash.Changeset.for_update(record, :submit_waitlist, params), ash_opts)
      :mark_payment_succeeded ->
        Ash.update(Ash.Changeset.for_update(record, :mark_payment_succeeded, params), ash_opts)
      :mark_booked ->
        Ash.update(Ash.Changeset.for_update(record, :mark_booked, params), ash_opts)
      :fulfill_waitlist ->
        Ash.update(Ash.Changeset.for_update(record, :fulfill_waitlist, params), ash_opts)
      :cancel_waitlist ->
        Ash.update(Ash.Changeset.for_update(record, :cancel_waitlist, params), ash_opts)
      :request_cancel ->
        Ash.update(Ash.Changeset.for_update(record, :request_cancel, params), ash_opts)
      :approve_cancel ->
        Ash.update(Ash.Changeset.for_update(record, :approve_cancel, params), ash_opts)
      :request_change ->
        Ash.update(Ash.Changeset.for_update(record, :request_change, params), ash_opts)
      :confirm_change ->
        Ash.update(Ash.Changeset.for_update(record, :confirm_change, params), ash_opts)
      :mark_completed ->
        Ash.update(Ash.Changeset.for_update(record, :mark_completed, params), ash_opts)
      :mark_order_failed ->
        Ash.update(Ash.Changeset.for_update(record, :mark_order_failed, params), ash_opts)
      :destroy ->
        Ash.destroy(Ash.Changeset.for_destroy(record, :destroy, params), ash_opts)
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
      :create_order -> [:update, :confirm_quote, :destroy]
      :update -> [:confirm_quote, :destroy]
      :confirm_quote -> [:submit_order, :submit_waitlist]
      :submit_order -> [:mark_payment_succeeded, :mark_order_failed]
      :submit_waitlist -> [:mark_payment_succeeded, :mark_order_failed]
      :mark_payment_succeeded -> [:mark_booked, :fulfill_waitlist, :cancel_waitlist]
      :mark_booked -> [:mark_completed, :request_cancel, :request_change]
      :fulfill_waitlist -> [:mark_completed, :request_cancel, :request_change]
      :cancel_waitlist -> [:request_cancel]
      :request_cancel -> [:approve_cancel]
      :approve_cancel -> [:request_change]
      :request_change -> [:confirm_change]
      :confirm_change -> [:mark_completed]
      :mark_completed -> [:mark_order_failed]
      :mark_order_failed -> [:destroy]
      :destroy -> []
      _ -> []
    end
  end

  defp on_error_candidates(step) do
    case step do
      :create_order -> []
      :update -> []
      :confirm_quote -> []
      :submit_order -> []
      :submit_waitlist -> []
      :mark_payment_succeeded -> []
      :mark_booked -> []
      :fulfill_waitlist -> []
      :cancel_waitlist -> []
      :request_cancel -> []
      :approve_cancel -> []
      :request_change -> []
      :confirm_change -> []
      :mark_completed -> []
      :mark_order_failed -> []
      :destroy -> []
      _ -> []
    end
  end

  defp branch_next(step, record) do
    _ = record
    case step do
      :create_order -> nil
      :update -> nil
      :confirm_quote -> nil
      :submit_order -> nil
      :submit_waitlist -> nil
      :mark_payment_succeeded -> nil
      :mark_booked -> nil
      :fulfill_waitlist -> nil
      :cancel_waitlist -> nil
      :request_cancel -> nil
      :approve_cancel -> nil
      :request_change -> nil
      :confirm_change -> nil
      :mark_completed -> nil
      :mark_order_failed -> nil
      :destroy -> nil
      _ -> nil
    end
  end

  defp step_skipped?(step, record) do
    _ = record
    case step do
      :create_order -> false
      :update -> false
      :confirm_quote -> false
      :submit_order -> false
      :submit_waitlist -> false
      :mark_payment_succeeded -> false
      :mark_booked -> false
      :fulfill_waitlist -> false
      :cancel_waitlist -> false
      :request_cancel -> false
      :approve_cancel -> false
      :request_change -> false
      :confirm_change -> false
      :mark_completed -> false
      :mark_order_failed -> false
      :destroy -> false
      _ -> false
    end
  end

  defp retry_policy(step) do
    case step do
      :create_order -> %{max_attempts: 1, backoff_ms: 0}
      :update -> %{max_attempts: 1, backoff_ms: 0}
      :confirm_quote -> %{max_attempts: 1, backoff_ms: 0}
      :submit_order -> %{max_attempts: 1, backoff_ms: 0}
      :submit_waitlist -> %{max_attempts: 1, backoff_ms: 0}
      :mark_payment_succeeded -> %{max_attempts: 1, backoff_ms: 0}
      :mark_booked -> %{max_attempts: 1, backoff_ms: 0}
      :fulfill_waitlist -> %{max_attempts: 1, backoff_ms: 0}
      :cancel_waitlist -> %{max_attempts: 1, backoff_ms: 0}
      :request_cancel -> %{max_attempts: 1, backoff_ms: 0}
      :approve_cancel -> %{max_attempts: 1, backoff_ms: 0}
      :request_change -> %{max_attempts: 1, backoff_ms: 0}
      :confirm_change -> %{max_attempts: 1, backoff_ms: 0}
      :mark_completed -> %{max_attempts: 1, backoff_ms: 0}
      :mark_order_failed -> %{max_attempts: 1, backoff_ms: 0}
      :destroy -> %{max_attempts: 1, backoff_ms: 0}
      _ -> %{max_attempts: 1, backoff_ms: 0}
    end
  end

  defp step_idempotency_source(step) do
    case step do
      :create_order -> nil
      :update -> nil
      :confirm_quote -> nil
      :submit_order -> nil
      :submit_waitlist -> nil
      :mark_payment_succeeded -> nil
      :mark_booked -> nil
      :fulfill_waitlist -> nil
      :cancel_waitlist -> nil
      :request_cancel -> nil
      :approve_cancel -> nil
      :request_change -> nil
      :confirm_change -> nil
      :mark_completed -> nil
      :mark_order_failed -> nil
      :destroy -> nil
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
