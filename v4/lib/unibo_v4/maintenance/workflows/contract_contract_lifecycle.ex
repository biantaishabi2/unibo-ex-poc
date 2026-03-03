defmodule UniboV4.Maintenance.Workflows.Contract.ContractLifecycleWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  alias UniboV4.Maintenance.Contract

  def steps do
    [:create, :action_open, :action_expire, :action_close, :action_draft]
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
        Ash.create(Ash.Changeset.for_create(Contract, :create, params), actor: actor)
      :action_open ->
        Ash.update(Ash.Changeset.for_update(record, :action_open, params), actor: actor)
      :action_expire ->
        Ash.update(Ash.Changeset.for_update(record, :action_expire, params), actor: actor)
      :action_close ->
        Ash.update(Ash.Changeset.for_update(record, :action_close, params), actor: actor)
      :action_draft ->
        Ash.update(Ash.Changeset.for_update(record, :action_draft, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
