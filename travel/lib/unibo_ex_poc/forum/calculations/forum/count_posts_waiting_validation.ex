defmodule UniboExPoc.Forum.Calculations.Forum.CountPostsWaitingValidation do
  @moduledoc """
  Calculation 模块: :count_posts_waiting_validation (type: :integer, entity: forum)
  原始 expr: op: func args: - count - op: filter   args:   - op: ref     args:     - posts   - op: eq     args:     - op: ref       args:       - state     - pending
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :count_posts_waiting_validation 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
