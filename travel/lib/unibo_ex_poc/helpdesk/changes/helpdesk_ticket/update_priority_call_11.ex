defmodule UniboExPoc.Helpdesk.Changes.HelpdeskTicket.UpdatePriorityCall11 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Helpdesk, :update_sla_deadline, 2) do
      Helpdesk.update_sla_deadline(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Helpdesk.update_sla_deadline/2")
    end
  end
end
