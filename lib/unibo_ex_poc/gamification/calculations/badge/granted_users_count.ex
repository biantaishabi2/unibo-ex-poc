defmodule UniboV4.Gamification.Calculations.Badge.GrantedUsersCount do
  @moduledoc """
  Calculation 模块: :granted_users_count (type: :integer, entity: badge)
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :granted_users_count 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
