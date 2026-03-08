defmodule UniboExPoc.Spreadsheet.Calculations.GlobalFilter.CurrentValue do
  @moduledoc """
  Calculation 模块: :current_value (type: :string, entity: global_filter)
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :current_value 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
