defmodule UniboExPoc.Delivery.Calculations.Shipment.PackageCount do
  @moduledoc """
  Calculation 模块: :package_count (type: :integer, entity: shipment)
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :package_count 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
