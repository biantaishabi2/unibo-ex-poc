defmodule UniboV4.Project.Workflows.Milestone.MilestoneWriteFlowWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  alias UniboV4.Project.Milestone

  def steps do
    [:create, :reach]
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
        Ash.create(Ash.Changeset.for_create(Milestone, :create, params), actor: actor)
      :reach ->
        Ash.update(Ash.Changeset.for_update(record, :reach, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
