defmodule UniboV4.Rental.Calculations.RentalOrderLine.IsLate do
  @moduledoc """
  Calculation 模块: :is_late (type: :boolean, entity: rental_order_line)
  原始 expr: op: and args: - op: neq   args:   - op: ref     args:     - actual_return_date   - null - op: gt   args:   - op: ref     args:     - actual_return_date   - op: ref     args:     - return_date
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :is_late 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
