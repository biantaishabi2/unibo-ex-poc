defmodule HospitalScheduling.AsyncRuntime.Queue do
  @moduledoc """
  异步任务队列入口。

  特性：
  - 幂等去重（dedup_key）
  - 失败重试（指数退避）
  - 可追踪字段（trace_id）
  """

  use GenServer

  alias HospitalScheduling.AsyncRuntime.Store
  alias HospitalScheduling.AsyncRuntime.Telemetry

  @default_max_attempts 3
  @default_retry_base_ms 1_000

  def start_link(_opts), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  @impl true
  def init(state), do: {:ok, state}

  def enqueue(attrs \\ %{}) when is_map(attrs) do
    dedup_key = Map.get(attrs, :dedup_key) || Map.get(attrs, "dedup_key")

    with :ok <- ensure_not_duplicate(dedup_key) do
      now = DateTime.utc_now()
      id = random_id()
      trace_id = Map.get(attrs, :trace_id) || Map.get(attrs, "trace_id") || id

      task = %{
        id: id,
        kind: Map.get(attrs, :kind) || Map.get(attrs, "kind") || "generic",
        payload: Map.get(attrs, :payload) || Map.get(attrs, "payload") || %{},
        state: :queued,
        dedup_key: dedup_key,
        trace_id: trace_id,
        attempt: 0,
        max_attempts: Map.get(attrs, :max_attempts) || Map.get(attrs, "max_attempts") || @default_max_attempts,
        next_run_at: nil,
        inserted_at: now,
        updated_at: now
      }

      {:ok, saved} = Store.put(task)
      Telemetry.emit_transition(nil, :queued, saved)
      {:ok, saved}
    else
      {:error, :duplicate} ->
        Telemetry.emit_enqueue_result(:duplicate, %{dedup_key: dedup_key})
        {:ok, :duplicate}
    end
  end

  def dequeue do
    promote_retry_tasks()

    with {:ok, tasks} <- Store.list(%{state: :queued}),
         [task | _] <- tasks,
         {:ok, running} <- Store.update(task.id, %{state: :running, updated_at: DateTime.utc_now()}) do
      Telemetry.emit_transition(:queued, :running, running)
      {:ok, running}
    else
      [] -> :empty
      _ -> :empty
    end
  end

  def ack(task_id, result \\ %{}) do
    with {:ok, task} <- Store.fetch(task_id),
         {:ok, updated} <-
           Store.update(task_id, %{
             state: :succeeded,
             result: result,
             updated_at: DateTime.utc_now(),
             next_run_at: nil
           }) do
      Telemetry.emit_transition(task.state, :succeeded, updated)
      {:ok, updated}
    end
  end

  def fail(task_id, error, opts \\ []) do
    with {:ok, task} <- Store.fetch(task_id) do
      next_attempt = task.attempt + 1
      max_attempts = task.max_attempts || @default_max_attempts

      if next_attempt < max_attempts do
        retry_in_ms = Keyword.get(opts, :retry_in_ms, retry_interval_ms(next_attempt))
        next_run_at = DateTime.add(DateTime.utc_now(), retry_in_ms, :millisecond)

        {:ok, updated} =
          Store.update(task_id, %{
            state: :retry_scheduled,
            attempt: next_attempt,
            last_error: inspect(error),
            next_run_at: next_run_at,
            updated_at: DateTime.utc_now()
          })

        Telemetry.emit_transition(task.state, :retry_scheduled, updated)
        {:retry_scheduled, updated}
      else
        {:ok, updated} =
          Store.update(task_id, %{
            state: :dead_letter,
            attempt: next_attempt,
            last_error: inspect(error),
            next_run_at: nil,
            updated_at: DateTime.utc_now()
          })

        Telemetry.emit_transition(task.state, :dead_letter, updated)
        {:dead_letter, updated}
      end
    end
  end

  defp ensure_not_duplicate(nil), do: :ok

  defp ensure_not_duplicate(dedup_key) do
    case Store.find_by_dedup_key(dedup_key) do
      {:ok, _task} -> {:error, :duplicate}
      _ -> :ok
    end
  end

  defp promote_retry_tasks do
    with {:ok, retrying} <- Store.list(%{state: :retry_scheduled}) do
      now = DateTime.utc_now()

      Enum.each(retrying, fn task ->
        due? = is_nil(task.next_run_at) || DateTime.compare(task.next_run_at, now) != :gt

        if due? do
          {:ok, updated} = Store.update(task.id, %{state: :queued, updated_at: now})
          Telemetry.emit_transition(:retry_scheduled, :queued, updated)
        end
      end)
    end
  end

  defp retry_interval_ms(attempt) when is_integer(attempt) and attempt >= 1 do
    trunc(:math.pow(2, attempt - 1) * @default_retry_base_ms)
  end

  defp random_id do
    :crypto.strong_rand_bytes(12)
    |> Base.url_encode64(padding: false)
  end
end
