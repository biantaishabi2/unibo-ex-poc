defmodule UniboExPoc.Ecommerce.Calculations.ProductVariant.CombinationInfoHasDiscountedPrice do
  @moduledoc """
  Calculation 模块: :combination_info_has_discounted_price (type: :boolean, entity: product_variant)
  原始 expr: op: custom args: []
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :combination_info_has_discounted_price 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
