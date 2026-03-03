defmodule UniboV4.Maintenance.Workflows.RepairOrder.RepairOrderLifecycleWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  alias UniboV4.Maintenance.RepairOrder

  def steps do
    [:create, :confirm, :start_repair, :complete_repair, :cancel, :reset_to_draft]
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
        Ash.create(Ash.Changeset.for_create(RepairOrder, :create, params), actor: actor)
      :confirm ->
        Ash.update(Ash.Changeset.for_update(record, :confirm, params), actor: actor)
      :start_repair ->
        Ash.update(Ash.Changeset.for_update(record, :start_repair, params), actor: actor)
      :complete_repair ->
        Ash.update(Ash.Changeset.for_update(record, :complete_repair, params), actor: actor)
      :cancel ->
        Ash.update(Ash.Changeset.for_update(record, :cancel, params), actor: actor)
      :reset_to_draft ->
        Ash.update(Ash.Changeset.for_update(record, :reset_to_draft, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
