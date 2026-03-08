defmodule UniboV4.Gamification.Calculations.Challenge.UserCount do
  @moduledoc """
  Calculation 模块: :user_count (type: :integer, entity: challenge)
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :user_count 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
