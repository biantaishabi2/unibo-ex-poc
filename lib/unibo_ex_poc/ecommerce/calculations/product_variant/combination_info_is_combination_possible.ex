defmodule UniboV4.Ecommerce.Calculations.ProductVariant.CombinationInfoIsCombinationPossible do
  @moduledoc """
  Calculation 模块: :combination_info_is_combination_possible (type: :boolean, entity: product_variant)
  原始 expr: op: custom args: []
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :combination_info_is_combination_possible 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
