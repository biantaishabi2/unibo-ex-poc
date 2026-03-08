defmodule UniboV4.PLM.Calculations.Eco.IsConflict do
  @moduledoc """
  Calculation 模块: :is_conflict (type: :boolean, entity: eco)
  原始 expr: op: custom args: - check_bom_conflict
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :is_conflict 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
