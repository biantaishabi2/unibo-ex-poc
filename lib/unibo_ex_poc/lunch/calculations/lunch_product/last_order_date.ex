defmodule UniboV4.Lunch.Calculations.LunchProduct.LastOrderDate do
  @moduledoc """
  Calculation 模块: :last_order_date (type: :date, entity: lunch_product)
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :last_order_date 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
