defmodule UniboExPoc.Survey.Calculations.Survey.ScoringMaxObtainable do
  @moduledoc """
  Calculation 模块: :scoring_max_obtainable (type: :float, entity: survey)
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :scoring_max_obtainable 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
