defmodule UniboV4.Membership.Calculations.MembershipLine.IsActive do
  @moduledoc """
  Calculation 模块: :is_active (type: :boolean, entity: membership_line)
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :is_active 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
