defmodule UniboExPoc.Lunch.Calculations.LunchSupplier.ShowConfirmButton do
  @moduledoc """
  Calculation 模块: :show_confirm_button (type: :boolean, entity: lunch_supplier)
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :show_confirm_button 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
