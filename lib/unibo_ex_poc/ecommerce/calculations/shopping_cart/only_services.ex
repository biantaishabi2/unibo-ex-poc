defmodule UniboV4.Ecommerce.Calculations.ShoppingCart.OnlyServices do
  @moduledoc """
  Calculation 模块: :only_services (type: :boolean, entity: shopping_cart)
  原始 expr: op: custom args: []
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :only_services 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
