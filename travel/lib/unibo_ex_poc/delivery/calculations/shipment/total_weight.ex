defmodule UniboExPoc.Delivery.Calculations.Shipment.TotalWeight do
  @moduledoc """
  Calculation 模块: :total_weight (type: :decimal, entity: shipment)
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :total_weight 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
