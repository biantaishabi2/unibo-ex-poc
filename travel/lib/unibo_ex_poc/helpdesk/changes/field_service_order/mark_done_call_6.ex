defmodule UniboExPoc.Helpdesk.Changes.FieldServiceOrder.MarkDoneCall6 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Helpdesk, :trigger_invoice_creation, 2) do
      Helpdesk.trigger_invoice_creation(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Helpdesk.trigger_invoice_creation/2")
    end
  end
end
