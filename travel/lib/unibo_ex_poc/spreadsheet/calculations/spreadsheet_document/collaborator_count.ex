defmodule UniboExPoc.Spreadsheet.Calculations.SpreadsheetDocument.CollaboratorCount do
  @moduledoc """
  Calculation 模块: :collaborator_count (type: :integer, entity: spreadsheet_document)
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :collaborator_count 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
