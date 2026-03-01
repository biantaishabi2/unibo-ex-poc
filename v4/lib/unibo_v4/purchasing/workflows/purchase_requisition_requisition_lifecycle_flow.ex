defmodule UniboV4.Purchasing.Workflows.PurchaseRequisition.RequisitionLifecycleFlowWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  alias UniboV4.Purchasing.PurchaseRequisition

  def steps do
    [:create, :action_in_progress, :action_open, :action_done, :action_cancel]
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
        Ash.create(Ash.Changeset.for_create(PurchaseRequisition, :create, params), actor: actor)
      :action_in_progress ->
        Ash.update(Ash.Changeset.for_update(record, :action_in_progress, params), actor: actor)
      :action_open ->
        Ash.update(Ash.Changeset.for_update(record, :action_open, params), actor: actor)
      :action_done ->
        Ash.update(Ash.Changeset.for_update(record, :action_done, params), actor: actor)
      :action_cancel ->
        Ash.update(Ash.Changeset.for_update(record, :action_cancel, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
