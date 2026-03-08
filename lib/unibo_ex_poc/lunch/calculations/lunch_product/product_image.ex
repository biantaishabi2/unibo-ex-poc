defmodule UniboV4.Lunch.Calculations.LunchProduct.ProductImage do
  @moduledoc """
  Calculation 模块: :product_image (type: :string, entity: lunch_product)
  原始 expr: op: coalesce args: - op: ref   args:   - image - op: ref   args:   - category   - image
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :product_image 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
