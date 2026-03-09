defmodule UniboExPoc.IoT.Workflows.VoIpCall.VoipCallLifecycleFlowWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  支持分支路由、失败回退、重试与幂等扩展钩子。
  """

  alias UniboExPoc.IoT.VoIPCall

  def steps do
    [:create, :answer, :hold, :unhold, :transfer, :add_note, :end_call, :miss, :to_voicemail, :update]
  end

  @workflow_semantics_json ~S"""
{"steps":[{"idempotency_key":null,"next":["answer"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"create"},{"idempotency_key":null,"next":["hold"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"answer"},{"idempotency_key":null,"next":["unhold"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"hold"},{"idempotency_key":null,"next":["transfer"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"unhold"},{"idempotency_key":null,"next":["add_note"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"transfer"},{"idempotency_key":null,"next":["end_call"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"add_note"},{"idempotency_key":null,"next":["miss"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"end_call"},{"idempotency_key":null,"next":["to_voicemail"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"miss"},{"idempotency_key":null,"next":["update"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"to_voicemail"},{"idempotency_key":null,"next":[],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"update"}],"workflow":"voip_call_lifecycle_flow"}
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
        Ash.create(Ash.Changeset.for_create(VoIPCall, :create, params), ash_opts)
      :answer ->
        Ash.update(Ash.Changeset.for_update(record, :answer, params), ash_opts)
      :hold ->
        Ash.update(Ash.Changeset.for_update(record, :hold, params), ash_opts)
      :unhold ->
        Ash.update(Ash.Changeset.for_update(record, :unhold, params), ash_opts)
      :transfer ->
        Ash.update(Ash.Changeset.for_update(record, :transfer, params), ash_opts)
      :add_note ->
        Ash.update(Ash.Changeset.for_update(record, :add_note, params), ash_opts)
      :end_call ->
        Ash.update(Ash.Changeset.for_update(record, :end_call, params), ash_opts)
      :miss ->
        Ash.update(Ash.Changeset.for_update(record, :miss, params), ash_opts)
      :to_voicemail ->
        Ash.update(Ash.Changeset.for_update(record, :to_voicemail, params), ash_opts)
      :update ->
        Ash.update(Ash.Changeset.for_update(record, :update, params), ash_opts)
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
      :create -> [:answer]
      :answer -> [:hold]
      :hold -> [:unhold]
      :unhold -> [:transfer]
      :transfer -> [:add_note]
      :add_note -> [:end_call]
      :end_call -> [:miss]
      :miss -> [:to_voicemail]
      :to_voicemail -> [:update]
      :update -> []
      _ -> []
    end
  end

  defp on_error_candidates(step) do
    case step do
      :create -> []
      :answer -> []
      :hold -> []
      :unhold -> []
      :transfer -> []
      :add_note -> []
      :end_call -> []
      :miss -> []
      :to_voicemail -> []
      :update -> []
      _ -> []
    end
  end

  defp branch_next(step, record) do
    _ = record
    case step do
      :create -> nil
      :answer -> nil
      :hold -> nil
      :unhold -> nil
      :transfer -> nil
      :add_note -> nil
      :end_call -> nil
      :miss -> nil
      :to_voicemail -> nil
      :update -> nil
      _ -> nil
    end
  end

  defp step_skipped?(step, record) do
    _ = record
    case step do
      :create -> false
      :answer -> false
      :hold -> false
      :unhold -> false
      :transfer -> false
      :add_note -> false
      :end_call -> false
      :miss -> false
      :to_voicemail -> false
      :update -> false
      _ -> false
    end
  end

  defp retry_policy(step) do
    case step do
      :create -> %{max_attempts: 1, backoff_ms: 0}
      :answer -> %{max_attempts: 1, backoff_ms: 0}
      :hold -> %{max_attempts: 1, backoff_ms: 0}
      :unhold -> %{max_attempts: 1, backoff_ms: 0}
      :transfer -> %{max_attempts: 1, backoff_ms: 0}
      :add_note -> %{max_attempts: 1, backoff_ms: 0}
      :end_call -> %{max_attempts: 1, backoff_ms: 0}
      :miss -> %{max_attempts: 1, backoff_ms: 0}
      :to_voicemail -> %{max_attempts: 1, backoff_ms: 0}
      :update -> %{max_attempts: 1, backoff_ms: 0}
      _ -> %{max_attempts: 1, backoff_ms: 0}
    end
  end

  defp step_idempotency_source(step) do
    case step do
      :create -> nil
      :answer -> nil
      :hold -> nil
      :unhold -> nil
      :transfer -> nil
      :add_note -> nil
      :end_call -> nil
      :miss -> nil
      :to_voicemail -> nil
      :update -> nil
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
