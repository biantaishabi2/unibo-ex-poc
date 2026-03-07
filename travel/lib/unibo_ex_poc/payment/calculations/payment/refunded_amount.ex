defmodule UniboExPoc.Payment.Calculations.Payment.RefundedAmount do
  @moduledoc """
  Calculation 模块: :refunded_amount (type: :decimal, entity: payment)
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :refunded_amount 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
