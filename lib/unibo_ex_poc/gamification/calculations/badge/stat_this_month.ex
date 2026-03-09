defmodule UniboExPoc.Gamification.Calculations.Badge.StatThisMonth do
  @moduledoc """
  Calculation 模块: :stat_this_month (type: :integer, entity: badge)
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :stat_this_month 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
