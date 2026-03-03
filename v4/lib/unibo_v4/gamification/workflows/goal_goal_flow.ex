defmodule UniboV4.Gamification.Workflows.Goal.GoalFlowWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  alias UniboV4.Gamification.Goal

  def steps do
    [:create, :update, :action_start, :action_reach, :action_fail, :action_cancel]
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
        Ash.create(Ash.Changeset.for_create(Goal, :create, params), actor: actor)
      :update ->
        Ash.update(Ash.Changeset.for_update(record, :update, params), actor: actor)
      :action_start ->
        Ash.update(Ash.Changeset.for_update(record, :action_start, params), actor: actor)
      :action_reach ->
        Ash.update(Ash.Changeset.for_update(record, :action_reach, params), actor: actor)
      :action_fail ->
        Ash.update(Ash.Changeset.for_update(record, :action_fail, params), actor: actor)
      :action_cancel ->
        Ash.update(Ash.Changeset.for_update(record, :action_cancel, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
