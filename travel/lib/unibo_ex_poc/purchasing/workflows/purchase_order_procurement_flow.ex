defmodule UniboExPoc.Purchasing.Workflows.PurchaseOrder.ProcurementFlowWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  支持分支路由、失败回退、重试与幂等扩展钩子。
  """

  alias UniboExPoc.Purchasing.PurchaseOrder

  def steps do
    [:s1_create, :s2_print_quotation, :s3_send_rfq, :s4_button_confirm, :s5_button_approve, :s6_button_done, :s7_button_unlock, :s8_button_cancel, :s9_button_draft, :s10_action_create_invoice]
  end

  @workflow_semantics_json ~S"""
{"steps":[{"idempotency_key":null,"next":["print_quotation","send_rfq","button_confirm"],"next_step_ids":["s2_print_quotation","s3_send_rfq","s4_button_confirm"],"on_error":[],"on_error_step_ids":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"create","step_id":"s1_create"},{"idempotency_key":null,"next":["button_confirm","button_cancel","button_draft"],"next_step_ids":["s4_button_confirm","s8_button_cancel","s9_button_draft"],"on_error":[],"on_error_step_ids":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"print_quotation","step_id":"s2_print_quotation"},{"idempotency_key":null,"next":["button_confirm","button_cancel","button_draft"],"next_step_ids":["s4_button_confirm","s8_button_cancel","s9_button_draft"],"on_error":[],"on_error_step_ids":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"send_rfq","step_id":"s3_send_rfq"},{"idempotency_key":null,"next":["button_approve","button_done","button_cancel","action_create_invoice"],"next_step_ids":["s5_button_approve","s6_button_done","s8_button_cancel","s10_action_create_invoice"],"on_error":[],"on_error_step_ids":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"button_confirm","step_id":"s4_button_confirm"},{"idempotency_key":null,"next":["button_done","button_cancel","action_create_invoice"],"next_step_ids":["s6_button_done","s8_button_cancel","s10_action_create_invoice"],"on_error":[],"on_error_step_ids":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"button_approve","step_id":"s5_button_approve"},{"idempotency_key":null,"next":["button_unlock"],"next_step_ids":["s7_button_unlock"],"on_error":[],"on_error_step_ids":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"button_done","step_id":"s6_button_done"},{"idempotency_key":null,"next":["button_done","button_cancel","action_create_invoice"],"next_step_ids":["s6_button_done","s8_button_cancel","s10_action_create_invoice"],"on_error":[],"on_error_step_ids":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"button_unlock","step_id":"s7_button_unlock"},{"idempotency_key":null,"next":["button_draft"],"next_step_ids":["s9_button_draft"],"on_error":[],"on_error_step_ids":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"button_cancel","step_id":"s8_button_cancel"},{"idempotency_key":null,"next":["print_quotation","send_rfq","button_confirm"],"next_step_ids":["s2_print_quotation","s3_send_rfq","s4_button_confirm"],"on_error":[],"on_error_step_ids":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"button_draft","step_id":"s9_button_draft"},{"idempotency_key":null,"next":[],"next_step_ids":[],"on_error":[],"on_error_step_ids":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"action_create_invoice","step_id":"s10_action_create_invoice"}],"workflow":"procurement_flow"}
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
        Ash.create(Ash.Changeset.for_create(PurchaseOrder, :create, params), ash_opts)
      :s2_print_quotation ->
        Ash.update(Ash.Changeset.for_update(record, :print_quotation, params), ash_opts)
      :s3_send_rfq ->
        Ash.update(Ash.Changeset.for_update(record, :send_rfq, params), ash_opts)
      :s4_button_confirm ->
        Ash.update(Ash.Changeset.for_update(record, :button_confirm, params), ash_opts)
      :s5_button_approve ->
        Ash.update(Ash.Changeset.for_update(record, :button_approve, params), ash_opts)
      :s6_button_done ->
        Ash.update(Ash.Changeset.for_update(record, :button_done, params), ash_opts)
      :s7_button_unlock ->
        Ash.update(Ash.Changeset.for_update(record, :button_unlock, params), ash_opts)
      :s8_button_cancel ->
        Ash.update(Ash.Changeset.for_update(record, :button_cancel, params), ash_opts)
      :s9_button_draft ->
        Ash.update(Ash.Changeset.for_update(record, :button_draft, params), ash_opts)
      :s10_action_create_invoice ->
        Ash.create(Ash.Changeset.for_create(PurchaseOrder, :action_create_invoice, params), ash_opts)
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
      :s1_create -> [:s2_print_quotation, :s3_send_rfq, :s4_button_confirm]
      :s2_print_quotation -> [:s4_button_confirm, :s8_button_cancel, :s9_button_draft]
      :s3_send_rfq -> [:s4_button_confirm, :s8_button_cancel, :s9_button_draft]
      :s4_button_confirm -> [:s5_button_approve, :s6_button_done, :s8_button_cancel, :s10_action_create_invoice]
      :s5_button_approve -> [:s6_button_done, :s8_button_cancel, :s10_action_create_invoice]
      :s6_button_done -> [:s7_button_unlock]
      :s7_button_unlock -> [:s6_button_done, :s8_button_cancel, :s10_action_create_invoice]
      :s8_button_cancel -> [:s9_button_draft]
      :s9_button_draft -> [:s2_print_quotation, :s3_send_rfq, :s4_button_confirm]
      :s10_action_create_invoice -> []
      _ -> []
    end
  end

  defp on_error_candidates(step) do
    case step do
      :s1_create -> []
      :s2_print_quotation -> []
      :s3_send_rfq -> []
      :s4_button_confirm -> []
      :s5_button_approve -> []
      :s6_button_done -> []
      :s7_button_unlock -> []
      :s8_button_cancel -> []
      :s9_button_draft -> []
      :s10_action_create_invoice -> []
      _ -> []
    end
  end

  defp branch_next(step, _record) do
    case step do
      :s1_create -> nil
      :s2_print_quotation -> nil
      :s3_send_rfq -> nil
      :s4_button_confirm -> nil
      :s5_button_approve -> nil
      :s6_button_done -> nil
      :s7_button_unlock -> nil
      :s8_button_cancel -> nil
      :s9_button_draft -> nil
      :s10_action_create_invoice -> nil
      _ -> nil
    end
  end

  defp step_skipped?(step, _record) do
    case step do
      :s1_create -> false
      :s2_print_quotation -> false
      :s3_send_rfq -> false
      :s4_button_confirm -> false
      :s5_button_approve -> false
      :s6_button_done -> false
      :s7_button_unlock -> false
      :s8_button_cancel -> false
      :s9_button_draft -> false
      :s10_action_create_invoice -> false
      _ -> false
    end
  end

  defp retry_policy(step) do
    case step do
      :s1_create -> %{max_attempts: 1, backoff_ms: 0}
      :s2_print_quotation -> %{max_attempts: 1, backoff_ms: 0}
      :s3_send_rfq -> %{max_attempts: 1, backoff_ms: 0}
      :s4_button_confirm -> %{max_attempts: 1, backoff_ms: 0}
      :s5_button_approve -> %{max_attempts: 1, backoff_ms: 0}
      :s6_button_done -> %{max_attempts: 1, backoff_ms: 0}
      :s7_button_unlock -> %{max_attempts: 1, backoff_ms: 0}
      :s8_button_cancel -> %{max_attempts: 1, backoff_ms: 0}
      :s9_button_draft -> %{max_attempts: 1, backoff_ms: 0}
      :s10_action_create_invoice -> %{max_attempts: 1, backoff_ms: 0}
      _ -> %{max_attempts: 1, backoff_ms: 0}
    end
  end

  defp step_idempotency_source(step) do
    case step do
      :s1_create -> nil
      :s2_print_quotation -> nil
      :s3_send_rfq -> nil
      :s4_button_confirm -> nil
      :s5_button_approve -> nil
      :s6_button_done -> nil
      :s7_button_unlock -> nil
      :s8_button_cancel -> nil
      :s9_button_draft -> nil
      :s10_action_create_invoice -> nil
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
