defmodule UniboV4.Purchasing.Workflows.PurchaseOrder.ProcurementFlowWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  alias UniboV4.Purchasing.PurchaseOrder

  def steps do
    [:create, :print_quotation, :send_rfq, :button_confirm, :button_approve, :button_done, :button_unlock, :button_cancel, :button_draft, :action_create_invoice]
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
        Ash.create(Ash.Changeset.for_create(PurchaseOrder, :create, params), actor: actor)
      :print_quotation ->
        Ash.update(Ash.Changeset.for_update(record, :print_quotation, params), actor: actor)
      :send_rfq ->
        Ash.update(Ash.Changeset.for_update(record, :send_rfq, params), actor: actor)
      :button_confirm ->
        Ash.update(Ash.Changeset.for_update(record, :button_confirm, params), actor: actor)
      :button_approve ->
        Ash.update(Ash.Changeset.for_update(record, :button_approve, params), actor: actor)
      :button_done ->
        Ash.update(Ash.Changeset.for_update(record, :button_done, params), actor: actor)
      :button_unlock ->
        Ash.update(Ash.Changeset.for_update(record, :button_unlock, params), actor: actor)
      :button_cancel ->
        Ash.update(Ash.Changeset.for_update(record, :button_cancel, params), actor: actor)
      :button_draft ->
        Ash.update(Ash.Changeset.for_update(record, :button_draft, params), actor: actor)
      :action_create_invoice ->
        Ash.create(Ash.Changeset.for_create(PurchaseOrder, :action_create_invoice, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
