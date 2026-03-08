defmodule UniboV4.Documents.Calculations.Document.Thumbnail do
  @moduledoc """
  Calculation 模块: :thumbnail (type: :string, entity: document)
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :thumbnail 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
