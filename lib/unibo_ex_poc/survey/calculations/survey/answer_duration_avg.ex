defmodule UniboExPoc.Survey.Calculations.Survey.AnswerDurationAvg do
  @moduledoc """
  Calculation 模块: :answer_duration_avg (type: :float, entity: survey)
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :answer_duration_avg 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
