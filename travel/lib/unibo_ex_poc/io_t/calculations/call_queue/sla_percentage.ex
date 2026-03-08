defmodule UniboExPoc.IoT.Calculations.CallQueue.SlaPercentage do
  @moduledoc """
  Calculation 模块: :sla_percentage (type: :decimal, entity: call_queue)
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :sla_percentage 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
