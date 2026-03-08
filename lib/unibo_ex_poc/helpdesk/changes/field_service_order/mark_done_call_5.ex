defmodule UniboV4.Helpdesk.Changes.FieldServiceOrder.MarkDoneCall5 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Helpdesk, :trigger_inventory_deduction, 2) do
      Helpdesk.trigger_inventory_deduction(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Helpdesk.trigger_inventory_deduction/2")
    end
  end
end
