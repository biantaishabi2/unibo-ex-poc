defmodule UniboExPoc.Documents.Calculations.Document.MimetypeDisplay do
  @moduledoc """
  Calculation 模块: :mimetype_display (type: :string, entity: document)
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :mimetype_display 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
