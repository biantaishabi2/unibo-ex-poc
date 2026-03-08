defmodule UniboExPoc.PLM.Calculations.Eco.KanbanState do
  @moduledoc """
  Calculation 模块: :kanban_state (type: :atom, entity: eco)
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :kanban_state 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
