defmodule UniboV4.ELearning.Workflows.SlideProgress.ProgressTrackingWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  alias UniboV4.ELearning.SlideProgress

  def steps do
    [:create, :mark_completed, :mark_uncompleted, :complete_quiz, :action_like, :action_dislike]
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
      :create ->
        Ash.create(Ash.Changeset.for_create(SlideProgress, :create, params), actor: actor)
      :mark_completed ->
        Ash.update(Ash.Changeset.for_update(record, :mark_completed, params), actor: actor)
      :mark_uncompleted ->
        Ash.update(Ash.Changeset.for_update(record, :mark_uncompleted, params), actor: actor)
      :complete_quiz ->
        Ash.update(Ash.Changeset.for_update(record, :complete_quiz, params), actor: actor)
      :action_like ->
        Ash.update(Ash.Changeset.for_update(record, :action_like, params), actor: actor)
      :action_dislike ->
        Ash.update(Ash.Changeset.for_update(record, :action_dislike, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
