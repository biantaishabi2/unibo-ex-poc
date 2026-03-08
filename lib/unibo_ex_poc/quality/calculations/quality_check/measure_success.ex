defmodule UniboV4.Quality.Calculations.QualityCheck.MeasureSuccess do
  @moduledoc """
  Calculation 模块: :measure_success (type: :atom, entity: quality_check)
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :measure_success 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
