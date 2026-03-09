defmodule UniboExPoc.Survey.Calculations.Question.IsScoredQuestion do
  @moduledoc """
  Calculation 模块: :is_scored_question (type: :boolean, entity: question)
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :is_scored_question 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
