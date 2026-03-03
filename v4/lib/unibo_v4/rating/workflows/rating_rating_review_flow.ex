defmodule UniboV4.Rating.Workflows.Rating.RatingReviewFlowWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  alias UniboV4.Rating.Rating

  def steps do
    [:submit, :update, :approve, :reject, :flag]
  end

  def run(record, opts \\ []) do
    Enum.reduce_while(steps(), {:ok, record}, fn step, {:ok, current} ->
      case apply_step(current, step, opts) do
        {:ok, next_record} -> {:cont, {:ok, next_record}}
        {:error, reason} -> {:halt, {:error, %{step: step, reason: reason}}}
      end
    end)
  end

  defp apply_step(record, step, opts) do
    actor = Keyword.get(opts, :actor)
    params_by_step = Keyword.get(opts, :params, %{})
    params = Map.get(params_by_step, step, %{})

    case step do
      :submit ->
        Ash.create(Ash.Changeset.for_create(Rating, :submit, params), actor: actor)
      :update ->
        Ash.update(Ash.Changeset.for_update(record, :update, params), actor: actor)
      :approve ->
        Ash.update(Ash.Changeset.for_update(record, :approve, params), actor: actor)
      :reject ->
        Ash.update(Ash.Changeset.for_update(record, :reject, params), actor: actor)
      :flag ->
        Ash.update(Ash.Changeset.for_update(record, :flag, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
