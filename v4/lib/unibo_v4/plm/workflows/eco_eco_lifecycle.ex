defmodule UniboV4.PLM.Workflows.Eco.EcoLifecycleWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  alias UniboV4.PLM.Eco

  def steps do
    [:create, :advance_stage, :apply_changes, :rebase]
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
        Ash.create(Ash.Changeset.for_create(Eco, :create, params), actor: actor)
      :advance_stage ->
        Ash.update(Ash.Changeset.for_update(record, :advance_stage, params), actor: actor)
      :apply_changes ->
        Ash.update(Ash.Changeset.for_update(record, :apply_changes, params), actor: actor)
      :rebase ->
        Ash.update(Ash.Changeset.for_update(record, :rebase, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
