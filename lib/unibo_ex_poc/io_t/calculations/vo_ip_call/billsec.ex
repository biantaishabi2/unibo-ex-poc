defmodule UniboExPoc.IoT.Calculations.VoIpCall.Billsec do
  @moduledoc """
  Calculation 模块: :billsec (type: :integer, entity: vo_ip_call)
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :billsec 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
