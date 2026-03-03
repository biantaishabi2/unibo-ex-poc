defmodule UniboV4.CRM.Workflows.Lead.LeadLifecycleWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  alias UniboV4.CRM.Lead

  def steps do
    [:create, :convert_opportunity, :win, :lose, :assign_salesperson, :merge]
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
        Ash.create(Ash.Changeset.for_create(Lead, :create, params), actor: actor)
      :convert_opportunity ->
        Ash.update(Ash.Changeset.for_update(record, :convert_opportunity, params), actor: actor)
      :win ->
        Ash.update(Ash.Changeset.for_update(record, :win, params), actor: actor)
      :lose ->
        Ash.update(Ash.Changeset.for_update(record, :lose, params), actor: actor)
      :assign_salesperson ->
        Ash.update(Ash.Changeset.for_update(record, :assign_salesperson, params), actor: actor)
      :merge ->
        Ash.update(Ash.Changeset.for_update(record, :merge, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
