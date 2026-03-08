defmodule UniboV4.Purchasing.Calculations.PurchaseRequisitionItem.QtyOrdered do
  @moduledoc """
  Calculation 模块: :qty_ordered (type: :decimal, entity: purchase_requisition_item)
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :qty_ordered 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
