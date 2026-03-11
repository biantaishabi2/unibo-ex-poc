defmodule UniboExPoc.Delivery.Workflows.CrossOrgTransaction.CrossOrgTransactionLifecycleWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  支持分支路由、失败回退、重试与幂等扩展钩子。
  """

  alias UniboExPoc.Delivery.CrossOrgTransaction

  def steps do
    [:s1_create, :s2_update, :s3_confirm_source, :s4_create_mirror_purchase_order, :s5_mark_fulfilled, :s6_mark_settled, :s7_mark_failed, :s8_cancel]
  end

  @workflow_semantics_json ~S"""
{"steps":[{"idempotency_key":null,"next":["update","confirm_source","cancel"],"next_step_ids":["s2_update","s3_confirm_source","s8_cancel"],"on_error":[],"on_error_step_ids":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"create","step_id":"s1_create"},{"idempotency_key":null,"next":["confirm_source","cancel"],"next_step_ids":["s3_confirm_source","s8_cancel"],"on_error":[],"on_error_step_ids":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"update","step_id":"s2_update"},{"idempotency_key":null,"next":["create_mirror_purchase_order","mark_failed","cancel"],"next_step_ids":["s4_create_mirror_purchase_order","s7_mark_failed","s8_cancel"],"on_error":[],"on_error_step_ids":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"confirm_source","step_id":"s3_confirm_source"},{"idempotency_key":null,"next":["mark_fulfilled","mark_failed"],"next_step_ids":["s5_mark_fulfilled","s7_mark_failed"],"on_error":[],"on_error_step_ids":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"create_mirror_purchase_order","step_id":"s4_create_mirror_purchase_order"},{"idempotency_key":null,"next":["mark_settled","mark_failed"],"next_step_ids":["s6_mark_settled","s7_mark_failed"],"on_error":[],"on_error_step_ids":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"mark_fulfilled","step_id":"s5_mark_fulfilled"},{"idempotency_key":null,"next":["mark_failed"],"next_step_ids":["s7_mark_failed"],"on_error":[],"on_error_step_ids":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"mark_settled","step_id":"s6_mark_settled"},{"idempotency_key":null,"next":["cancel"],"next_step_ids":["s8_cancel"],"on_error":[],"on_error_step_ids":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"mark_failed","step_id":"s7_mark_failed"},{"idempotency_key":null,"next":[],"next_step_ids":[],"on_error":[],"on_error_step_ids":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"cancel","step_id":"s8_cancel"}],"workflow":"cross_org_transaction_lifecycle"}
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
      :s1_create ->
        Ash.create(Ash.Changeset.for_create(CrossOrgTransaction, :create, params), ash_opts)
      :s2_update ->
        Ash.update(Ash.Changeset.for_update(record, :update, params), ash_opts)
      :s3_confirm_source ->
        Ash.update(Ash.Changeset.for_update(record, :confirm_source, params), ash_opts)
      :s4_create_mirror_purchase_order ->
        Ash.update(Ash.Changeset.for_update(record, :create_mirror_purchase_order, params), ash_opts)
      :s5_mark_fulfilled ->
        Ash.update(Ash.Changeset.for_update(record, :mark_fulfilled, params), ash_opts)
      :s6_mark_settled ->
        Ash.update(Ash.Changeset.for_update(record, :mark_settled, params), ash_opts)
      :s7_mark_failed ->
        Ash.update(Ash.Changeset.for_update(record, :mark_failed, params), ash_opts)
      :s8_cancel ->
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
      :s1_create -> [:s2_update, :s3_confirm_source, :s8_cancel]
      :s2_update -> [:s3_confirm_source, :s8_cancel]
      :s3_confirm_source -> [:s4_create_mirror_purchase_order, :s7_mark_failed, :s8_cancel]
      :s4_create_mirror_purchase_order -> [:s5_mark_fulfilled, :s7_mark_failed]
      :s5_mark_fulfilled -> [:s6_mark_settled, :s7_mark_failed]
      :s6_mark_settled -> [:s7_mark_failed]
      :s7_mark_failed -> [:s8_cancel]
      :s8_cancel -> []
      _ -> []
    end
  end

  defp on_error_candidates(step) do
    case step do
      :s1_create -> []
      :s2_update -> []
      :s3_confirm_source -> []
      :s4_create_mirror_purchase_order -> []
      :s5_mark_fulfilled -> []
      :s6_mark_settled -> []
      :s7_mark_failed -> []
      :s8_cancel -> []
      _ -> []
    end
  end

  defp branch_next(step, _record) do
    case step do
      :s1_create -> nil
      :s2_update -> nil
      :s3_confirm_source -> nil
      :s4_create_mirror_purchase_order -> nil
      :s5_mark_fulfilled -> nil
      :s6_mark_settled -> nil
      :s7_mark_failed -> nil
      :s8_cancel -> nil
      _ -> nil
    end
  end

  defp step_skipped?(step, _record) do
    case step do
      :s1_create -> false
      :s2_update -> false
      :s3_confirm_source -> false
      :s4_create_mirror_purchase_order -> false
      :s5_mark_fulfilled -> false
      :s6_mark_settled -> false
      :s7_mark_failed -> false
      :s8_cancel -> false
      _ -> false
    end
  end

  defp retry_policy(step) do
    case step do
      :s1_create -> %{max_attempts: 1, backoff_ms: 0}
      :s2_update -> %{max_attempts: 1, backoff_ms: 0}
      :s3_confirm_source -> %{max_attempts: 1, backoff_ms: 0}
      :s4_create_mirror_purchase_order -> %{max_attempts: 1, backoff_ms: 0}
      :s5_mark_fulfilled -> %{max_attempts: 1, backoff_ms: 0}
      :s6_mark_settled -> %{max_attempts: 1, backoff_ms: 0}
      :s7_mark_failed -> %{max_attempts: 1, backoff_ms: 0}
      :s8_cancel -> %{max_attempts: 1, backoff_ms: 0}
      _ -> %{max_attempts: 1, backoff_ms: 0}
    end
  end

  defp step_idempotency_source(step) do
    case step do
      :s1_create -> nil
      :s2_update -> nil
      :s3_confirm_source -> nil
      :s4_create_mirror_purchase_order -> nil
      :s5_mark_fulfilled -> nil
      :s6_mark_settled -> nil
      :s7_mark_failed -> nil
      :s8_cancel -> nil
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
