defmodule UniboExPoc.Website.Calculations.Menu.IsActiveHighlight do
  @moduledoc """
  Calculation 模块: :is_active_highlight (type: :boolean, entity: menu)
  原始 expr: op: custom args: []
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :is_active_highlight 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
