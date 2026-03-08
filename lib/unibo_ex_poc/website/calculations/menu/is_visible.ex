defmodule UniboV4.Website.Calculations.Menu.IsVisible do
  @moduledoc """
  Calculation 模块: :is_visible (type: :boolean, entity: menu)
  原始 expr: op: custom args: []
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :is_visible 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
