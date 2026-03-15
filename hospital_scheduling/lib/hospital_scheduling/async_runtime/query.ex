defmodule HospitalScheduling.AsyncRuntime.Query do
  @moduledoc """
  异步任务查询入口：用于排障、追踪与监控面板。
  """

  alias HospitalScheduling.AsyncRuntime.Store

  def task(task_id), do: Store.fetch(task_id)
  def search(filters \\ %{}), do: Store.list(filters)

  def by_trace(trace_id), do: Store.list(%{trace_id: trace_id})

  def metrics do
    counts = Store.count_by_state()
    total = counts |> Map.values() |> Enum.sum()

    %{
      total: total,
      by_state: counts
    }
  end
end
