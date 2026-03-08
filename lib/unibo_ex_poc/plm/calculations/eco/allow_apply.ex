defmodule UniboV4.PLM.Calculations.Eco.AllowApply do
  @moduledoc """
  Calculation 模块: :allow_apply (type: :boolean, entity: eco)
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :allow_apply 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
