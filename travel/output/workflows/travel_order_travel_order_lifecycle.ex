defmodule Travel.Travel.Workflows.TravelOrder.TravelOrderLifecycleWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  支持分支路由、失败回退、重试与幂等扩展钩子。
  """

  alias Travel.Travel.TravelOrder

  def steps do
    [:s1_create, :s2_update, :s3_confirm_quote, :s4_submit_order, :s5_submit_waitlist, :s6_mark_payment_succeeded, :s7_mark_booked, :s8_fulfill_waitlist, :s9_cancel_waitlist, :s10_request_cancel, :s11_execute_cancel, :s12_cancel_cancel_request, :s13_request_change, :s14_confirm_change, :s15_mark_completed, :s16_mark_order_failed, :s17_destroy]
  end

  @workflow_semantics_json ~S"""
{"steps":[{"idempotency_key":null,"next":["update","confirm_quote","destroy"],"next_step_ids":["s2_update","s3_confirm_quote","s17_destroy"],"on_error":[],"on_error_step_ids":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"create","step_id":"s1_create"},{"idempotency_key":null,"next":["confirm_quote","destroy"],"next_step_ids":["s3_confirm_quote","s17_destroy"],"on_error":[],"on_error_step_ids":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"update","step_id":"s2_update"},{"idempotency_key":null,"next":["submit_order","submit_waitlist"],"next_step_ids":["s4_submit_order","s5_submit_waitlist"],"on_error":[],"on_error_step_ids":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"confirm_quote","step_id":"s3_confirm_quote"},{"idempotency_key":null,"next":["mark_payment_succeeded","mark_order_failed"],"next_step_ids":["s6_mark_payment_succeeded","s16_mark_order_failed"],"on_error":[],"on_error_step_ids":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"submit_order","step_id":"s4_submit_order"},{"idempotency_key":null,"next":["mark_payment_succeeded","mark_order_failed"],"next_step_ids":["s6_mark_payment_succeeded","s16_mark_order_failed"],"on_error":[],"on_error_step_ids":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"submit_waitlist","step_id":"s5_submit_waitlist"},{"idempotency_key":null,"next":["mark_booked","fulfill_waitlist","cancel_waitlist"],"next_step_ids":["s7_mark_booked","s8_fulfill_waitlist","s9_cancel_waitlist"],"on_error":[],"on_error_step_ids":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"mark_payment_succeeded","step_id":"s6_mark_payment_succeeded"},{"idempotency_key":null,"next":["mark_completed","request_cancel","request_change"],"next_step_ids":["s15_mark_completed","s10_request_cancel","s13_request_change"],"on_error":[],"on_error_step_ids":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"mark_booked","step_id":"s7_mark_booked"},{"idempotency_key":null,"next":["mark_completed","request_cancel","request_change"],"next_step_ids":["s15_mark_completed","s10_request_cancel","s13_request_change"],"on_error":[],"on_error_step_ids":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"fulfill_waitlist","step_id":"s8_fulfill_waitlist"},{"idempotency_key":null,"next":["request_cancel"],"next_step_ids":["s10_request_cancel"],"on_error":[],"on_error_step_ids":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"cancel_waitlist","step_id":"s9_cancel_waitlist"},{"idempotency_key":null,"next":["execute_cancel","cancel_cancel_request"],"next_step_ids":["s11_execute_cancel","s12_cancel_cancel_request"],"on_error":[],"on_error_step_ids":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"request_cancel","step_id":"s10_request_cancel"},{"idempotency_key":null,"next":["cancel_cancel_request"],"next_step_ids":["s12_cancel_cancel_request"],"on_error":[],"on_error_step_ids":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"execute_cancel","step_id":"s11_execute_cancel"},{"idempotency_key":null,"next":["mark_completed","request_cancel"],"next_step_ids":["s15_mark_completed","s10_request_cancel"],"on_error":[],"on_error_step_ids":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"cancel_cancel_request","step_id":"s12_cancel_cancel_request"},{"idempotency_key":null,"next":["confirm_change"],"next_step_ids":["s14_confirm_change"],"on_error":[],"on_error_step_ids":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"request_change","step_id":"s13_request_change"},{"idempotency_key":null,"next":["mark_completed"],"next_step_ids":["s15_mark_completed"],"on_error":[],"on_error_step_ids":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"confirm_change","step_id":"s14_confirm_change"},{"idempotency_key":null,"next":["mark_order_failed"],"next_step_ids":["s16_mark_order_failed"],"on_error":[],"on_error_step_ids":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"mark_completed","step_id":"s15_mark_completed"},{"idempotency_key":null,"next":["destroy"],"next_step_ids":["s17_destroy"],"on_error":[],"on_error_step_ids":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"mark_order_failed","step_id":"s16_mark_order_failed"},{"idempotency_key":null,"next":[],"next_step_ids":[],"on_error":[],"on_error_step_ids":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"destroy","step_id":"s17_destroy"}],"workflow":"travel_order_lifecycle"}
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
        Ash.create(Ash.Changeset.for_create(TravelOrder, :create, params), ash_opts)
      :s2_update ->
        Ash.update(Ash.Changeset.for_update(record, :update, params), ash_opts)
      :s3_confirm_quote ->
        Ash.update(Ash.Changeset.for_update(record, :confirm_quote, params), ash_opts)
      :s4_submit_order ->
        Ash.update(Ash.Changeset.for_update(record, :submit_order, params), ash_opts)
      :s5_submit_waitlist ->
        Ash.update(Ash.Changeset.for_update(record, :submit_waitlist, params), ash_opts)
      :s6_mark_payment_succeeded ->
        Ash.update(Ash.Changeset.for_update(record, :mark_payment_succeeded, params), ash_opts)
      :s7_mark_booked ->
        Ash.update(Ash.Changeset.for_update(record, :mark_booked, params), ash_opts)
      :s8_fulfill_waitlist ->
        Ash.update(Ash.Changeset.for_update(record, :fulfill_waitlist, params), ash_opts)
      :s9_cancel_waitlist ->
        Ash.update(Ash.Changeset.for_update(record, :cancel_waitlist, params), ash_opts)
      :s10_request_cancel ->
        Ash.update(Ash.Changeset.for_update(record, :request_cancel, params), ash_opts)
      :s11_execute_cancel ->
        Ash.update(Ash.Changeset.for_update(record, :execute_cancel, params), ash_opts)
      :s12_cancel_cancel_request ->
        Ash.update(Ash.Changeset.for_update(record, :cancel_cancel_request, params), ash_opts)
      :s13_request_change ->
        Ash.update(Ash.Changeset.for_update(record, :request_change, params), ash_opts)
      :s14_confirm_change ->
        Ash.update(Ash.Changeset.for_update(record, :confirm_change, params), ash_opts)
      :s15_mark_completed ->
        Ash.update(Ash.Changeset.for_update(record, :mark_completed, params), ash_opts)
      :s16_mark_order_failed ->
        Ash.update(Ash.Changeset.for_update(record, :mark_order_failed, params), ash_opts)
      :s17_destroy ->
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
      :s1_create -> [:s2_update, :s3_confirm_quote, :s17_destroy]
      :s2_update -> [:s3_confirm_quote, :s17_destroy]
      :s3_confirm_quote -> [:s4_submit_order, :s5_submit_waitlist]
      :s4_submit_order -> [:s6_mark_payment_succeeded, :s16_mark_order_failed]
      :s5_submit_waitlist -> [:s6_mark_payment_succeeded, :s16_mark_order_failed]
      :s6_mark_payment_succeeded -> [:s7_mark_booked, :s8_fulfill_waitlist, :s9_cancel_waitlist]
      :s7_mark_booked -> [:s15_mark_completed, :s10_request_cancel, :s13_request_change]
      :s8_fulfill_waitlist -> [:s15_mark_completed, :s10_request_cancel, :s13_request_change]
      :s9_cancel_waitlist -> [:s10_request_cancel]
      :s10_request_cancel -> [:s11_execute_cancel, :s12_cancel_cancel_request]
      :s11_execute_cancel -> [:s12_cancel_cancel_request]
      :s12_cancel_cancel_request -> [:s15_mark_completed, :s10_request_cancel]
      :s13_request_change -> [:s14_confirm_change]
      :s14_confirm_change -> [:s15_mark_completed]
      :s15_mark_completed -> [:s16_mark_order_failed]
      :s16_mark_order_failed -> [:s17_destroy]
      :s17_destroy -> []
      _ -> []
    end
  end

  defp on_error_candidates(step) do
    case step do
      :s1_create -> []
      :s2_update -> []
      :s3_confirm_quote -> []
      :s4_submit_order -> []
      :s5_submit_waitlist -> []
      :s6_mark_payment_succeeded -> []
      :s7_mark_booked -> []
      :s8_fulfill_waitlist -> []
      :s9_cancel_waitlist -> []
      :s10_request_cancel -> []
      :s11_execute_cancel -> []
      :s12_cancel_cancel_request -> []
      :s13_request_change -> []
      :s14_confirm_change -> []
      :s15_mark_completed -> []
      :s16_mark_order_failed -> []
      :s17_destroy -> []
      _ -> []
    end
  end

  defp branch_next(step, _record) do
    case step do
      :s1_create -> nil
      :s2_update -> nil
      :s3_confirm_quote -> nil
      :s4_submit_order -> nil
      :s5_submit_waitlist -> nil
      :s6_mark_payment_succeeded -> nil
      :s7_mark_booked -> nil
      :s8_fulfill_waitlist -> nil
      :s9_cancel_waitlist -> nil
      :s10_request_cancel -> nil
      :s11_execute_cancel -> nil
      :s12_cancel_cancel_request -> nil
      :s13_request_change -> nil
      :s14_confirm_change -> nil
      :s15_mark_completed -> nil
      :s16_mark_order_failed -> nil
      :s17_destroy -> nil
      _ -> nil
    end
  end

  defp step_skipped?(step, _record) do
    case step do
      :s1_create -> false
      :s2_update -> false
      :s3_confirm_quote -> false
      :s4_submit_order -> false
      :s5_submit_waitlist -> false
      :s6_mark_payment_succeeded -> false
      :s7_mark_booked -> false
      :s8_fulfill_waitlist -> false
      :s9_cancel_waitlist -> false
      :s10_request_cancel -> false
      :s11_execute_cancel -> false
      :s12_cancel_cancel_request -> false
      :s13_request_change -> false
      :s14_confirm_change -> false
      :s15_mark_completed -> false
      :s16_mark_order_failed -> false
      :s17_destroy -> false
      _ -> false
    end
  end

  defp retry_policy(step) do
    case step do
      :s1_create -> %{max_attempts: 1, backoff_ms: 0}
      :s2_update -> %{max_attempts: 1, backoff_ms: 0}
      :s3_confirm_quote -> %{max_attempts: 1, backoff_ms: 0}
      :s4_submit_order -> %{max_attempts: 1, backoff_ms: 0}
      :s5_submit_waitlist -> %{max_attempts: 1, backoff_ms: 0}
      :s6_mark_payment_succeeded -> %{max_attempts: 1, backoff_ms: 0}
      :s7_mark_booked -> %{max_attempts: 1, backoff_ms: 0}
      :s8_fulfill_waitlist -> %{max_attempts: 1, backoff_ms: 0}
      :s9_cancel_waitlist -> %{max_attempts: 1, backoff_ms: 0}
      :s10_request_cancel -> %{max_attempts: 1, backoff_ms: 0}
      :s11_execute_cancel -> %{max_attempts: 1, backoff_ms: 0}
      :s12_cancel_cancel_request -> %{max_attempts: 1, backoff_ms: 0}
      :s13_request_change -> %{max_attempts: 1, backoff_ms: 0}
      :s14_confirm_change -> %{max_attempts: 1, backoff_ms: 0}
      :s15_mark_completed -> %{max_attempts: 1, backoff_ms: 0}
      :s16_mark_order_failed -> %{max_attempts: 1, backoff_ms: 0}
      :s17_destroy -> %{max_attempts: 1, backoff_ms: 0}
      _ -> %{max_attempts: 1, backoff_ms: 0}
    end
  end

  defp step_idempotency_source(step) do
    case step do
      :s1_create -> nil
      :s2_update -> nil
      :s3_confirm_quote -> nil
      :s4_submit_order -> nil
      :s5_submit_waitlist -> nil
      :s6_mark_payment_succeeded -> nil
      :s7_mark_booked -> nil
      :s8_fulfill_waitlist -> nil
      :s9_cancel_waitlist -> nil
      :s10_request_cancel -> nil
      :s11_execute_cancel -> nil
      :s12_cancel_cancel_request -> nil
      :s13_request_change -> nil
      :s14_confirm_change -> nil
      :s15_mark_completed -> nil
      :s16_mark_order_failed -> nil
      :s17_destroy -> nil
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
