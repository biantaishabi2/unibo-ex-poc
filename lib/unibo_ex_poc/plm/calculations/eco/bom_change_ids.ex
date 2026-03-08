defmodule UniboV4.PLM.Calculations.Eco.BomChangeIds do
  @moduledoc """
  Calculation 模块: :bom_change_ids (type: {:array, :string}, entity: eco)
  原始 expr: op: custom args: - op: ref   args:   - bom   - bom_line_ids - op: ref   args:   - new_bom   - bom_line_ids
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :bom_change_ids 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
