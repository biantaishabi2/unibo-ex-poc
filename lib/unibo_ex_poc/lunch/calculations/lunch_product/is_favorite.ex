defmodule UniboV4.Lunch.Calculations.LunchProduct.IsFavorite do
  @moduledoc """
  Calculation 模块: :is_favorite (type: :boolean, entity: lunch_product)
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :is_favorite 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
