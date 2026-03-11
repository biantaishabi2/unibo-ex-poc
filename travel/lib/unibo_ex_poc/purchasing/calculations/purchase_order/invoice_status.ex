defmodule UniboExPoc.Purchasing.Calculations.PurchaseOrder.InvoiceStatus do
  @moduledoc """
  Calculation 模块: :invoice_status (type: :atom, entity: purchase_order)
  原始 expr: op: custom args: []
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :invoice_status 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
