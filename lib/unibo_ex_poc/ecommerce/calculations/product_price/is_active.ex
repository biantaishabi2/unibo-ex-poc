defmodule UniboV4.Ecommerce.Calculations.ProductPrice.IsActive do
  @moduledoc """
  Calculation 模块: :is_active (type: :boolean, entity: product_price)
  原始 expr: op: custom args: []
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :is_active 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
