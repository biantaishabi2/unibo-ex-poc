defmodule UniboV4.Forum.Calculations.Forum.TagUnusedIds do
  @moduledoc """
  Calculation 模块: :tag_unused_ids (type: {:array, :string}, entity: forum)
  原始 expr: op: filter args: - op: ref   args:   - tags - op: eq   args:   - op: ref     args:     - tags     - posts_count   - 0
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :tag_unused_ids 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
