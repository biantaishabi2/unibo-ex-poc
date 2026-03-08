defmodule UniboV4.Fleet.Calculations.FleetVehicle.TotalServiceCost do
  @moduledoc """
  Calculation 模块: :total_service_cost (type: :decimal, entity: fleet_vehicle)
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :total_service_cost 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
