defmodule UniboV4.Ecommerce.Calculations.ShoppingCart.IsAbandoned do
  @moduledoc """
  Calculation 模块: :is_abandoned (type: :boolean, entity: shopping_cart)
  原始 expr: op: custom args: []
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :is_abandoned 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
