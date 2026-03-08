defmodule UniboExPoc.Manufacturing.Workflows.ManufacturingOrder.ManufacturingOrderFlowWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  支持分支路由、失败回退、重试与幂等扩展钩子。
  """

  alias UniboExPoc.Manufacturing.ManufacturingOrder

  def steps do
    [:create, :confirm, :start, :produce, :mark_done, :complete, :split_production, :cancel]
  end

  @workflow_semantics_json ~S"""
{"steps":[{"idempotency_key":null,"next":["confirm"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"create"},{"idempotency_key":null,"next":["start"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"confirm"},{"idempotency_key":null,"next":["produce"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"start"},{"idempotency_key":null,"next":["mark_done"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"produce"},{"idempotency_key":null,"next":["complete"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"mark_done"},{"idempotency_key":null,"next":["split_production"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"complete"},{"idempotency_key":null,"next":["cancel"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"split_production"},{"idempotency_key":null,"next":[],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"cancel"}],"workflow":"manufacturing_order_flow"}
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
        Ash.create(Ash.Changeset.for_create(ManufacturingOrder, :create, params), ash_opts)
      :confirm ->
        Ash.update(Ash.Changeset.for_update(record, :confirm, params), ash_opts)
      :start ->
        Ash.update(Ash.Changeset.for_update(record, :start, params), ash_opts)
      :produce ->
        Ash.update(Ash.Changeset.for_update(record, :produce, params), ash_opts)
      :mark_done ->
        Ash.update(Ash.Changeset.for_update(record, :mark_done, params), ash_opts)
      :complete ->
        Ash.update(Ash.Changeset.for_update(record, :complete, params), ash_opts)
      :split_production ->
        Ash.update(Ash.Changeset.for_update(record, :split_production, params), ash_opts)
      :cancel ->
        Ash.update(Ash.Changeset.for_update(record, :cancel, params), ash_opts)
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
      :create -> [:confirm]
      :confirm -> [:start]
      :start -> [:produce]
      :produce -> [:mark_done]
      :mark_done -> [:complete]
      :complete -> [:split_production]
      :split_production -> [:cancel]
      :cancel -> []
      _ -> []
    end
  end

  defp on_error_candidates(step) do
    case step do
      :create -> []
      :confirm -> []
      :start -> []
      :produce -> []
      :mark_done -> []
      :complete -> []
      :split_production -> []
      :cancel -> []
      _ -> []
    end
  end

  defp branch_next(step, record) do
    case step do
      :create -> nil
      :confirm -> nil
      :start -> nil
      :produce -> nil
      :mark_done -> nil
      :complete -> nil
      :split_production -> nil
      :cancel -> nil
      _ -> nil
    end
  end

  defp step_skipped?(step, record) do
    case step do
      :create -> false
      :confirm -> false
      :start -> false
      :produce -> false
      :mark_done -> false
      :complete -> false
      :split_production -> false
      :cancel -> false
      _ -> false
    end
  end

  defp retry_policy(step) do
    case step do
      :create -> %{max_attempts: 1, backoff_ms: 0}
      :confirm -> %{max_attempts: 1, backoff_ms: 0}
      :start -> %{max_attempts: 1, backoff_ms: 0}
      :produce -> %{max_attempts: 1, backoff_ms: 0}
      :mark_done -> %{max_attempts: 1, backoff_ms: 0}
      :complete -> %{max_attempts: 1, backoff_ms: 0}
      :split_production -> %{max_attempts: 1, backoff_ms: 0}
      :cancel -> %{max_attempts: 1, backoff_ms: 0}
      _ -> %{max_attempts: 1, backoff_ms: 0}
    end
  end

  defp step_idempotency_source(step) do
    case step do
      :create -> nil
      :confirm -> nil
      :start -> nil
      :produce -> nil
      :mark_done -> nil
      :complete -> nil
      :split_production -> nil
      :cancel -> nil
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
