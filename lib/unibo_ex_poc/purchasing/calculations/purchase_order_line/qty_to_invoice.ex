defmodule UniboV4.Purchasing.Calculations.PurchaseOrderLine.QtyToInvoice do
  @moduledoc """
  Calculation 模块: :qty_to_invoice (type: :decimal, entity: purchase_order_line)
  原始 expr: op: custom args: []
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :qty_to_invoice 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
