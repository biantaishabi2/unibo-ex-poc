defmodule UniboV4.Purchasing.Calculations.PurchaseOrder.DatePlanned do
  @moduledoc """
  Calculation 模块: :date_planned (type: :utc_datetime, entity: purchase_order)
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :date_planned 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
