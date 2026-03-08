defmodule UniboV4.IoT.Calculations.CallQueue.AvgWaitTime do
  @moduledoc """
  Calculation 模块: :avg_wait_time (type: :integer, entity: call_queue)
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :avg_wait_time 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
