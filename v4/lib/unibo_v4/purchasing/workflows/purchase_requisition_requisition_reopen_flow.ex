defmodule UniboV4.Purchasing.Workflows.PurchaseRequisition.RequisitionReopenFlowWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  def steps do
    [:action_cancel, :action_draft, :action_in_progress]
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
      :action_cancel ->
        Ash.update(Ash.Changeset.for_update(record, :action_cancel, params), actor: actor)
      :action_draft ->
        Ash.update(Ash.Changeset.for_update(record, :action_draft, params), actor: actor)
      :action_in_progress ->
        Ash.update(Ash.Changeset.for_update(record, :action_in_progress, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
