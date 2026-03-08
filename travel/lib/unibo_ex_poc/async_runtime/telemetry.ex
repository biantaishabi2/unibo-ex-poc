defmodule UniboExPoc.AsyncRuntime.Telemetry do
  @moduledoc """
  异步执行层观测入口。

  指标：
  - queue depth（分状态）
  - state transition（状态迁移）
  - enqueue dedup result（入队去重结果）
  """

  use GenServer
  alias UniboExPoc.AsyncRuntime.Store

  @tick_ms 10_000

  def start_link(_opts), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  def emit_transition(from_state, to_state, task) do
    :telemetry.execute(
      [:unibo, :async_runtime, :task, :transition],
      %{count: 1},
      %{
        from: from_state,
        to: to_state,
        task_id: task.id,
        trace_id: task.trace_id,
        dedup_key: task.dedup_key,
        attempt: task.attempt
      }
    )
  end

  def emit_enqueue_result(result, metadata \\ %{}) do
    :telemetry.execute(
      [:unibo, :async_runtime, :enqueue, :result],
      %{count: 1},
      Map.put(metadata, :result, result)
    )
  end

  @impl true
  def init(state) do
    :timer.send_interval(@tick_ms, :collect_queue_depth)
    {:ok, state}
  end

  @impl true
  def handle_info(:collect_queue_depth, state) do
    counters = Store.count_by_state()

    Enum.each(counters, fn {task_state, count} ->
      :telemetry.execute(
        [:unibo, :async_runtime, :queue, :depth],
        %{value: count},
        %{state: task_state}
      )
    end)

    {:noreply, state}
  end
end
