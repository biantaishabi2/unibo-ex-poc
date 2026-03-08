defmodule UniboV4.Purchasing.Calculations.PurchaseOrder.TaxCountryId do
  @moduledoc """
  Calculation 模块: :tax_country_id (type: :uuid, entity: purchase_order)
  原始 expr: op: custom args: []
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :tax_country_id 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
