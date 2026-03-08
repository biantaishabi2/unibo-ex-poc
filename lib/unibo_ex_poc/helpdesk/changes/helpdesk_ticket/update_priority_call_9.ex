defmodule UniboV4.Helpdesk.Changes.HelpdeskTicket.UpdatePriorityCall9 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Helpdesk, :match_sla_policies, 2) do
      Helpdesk.match_sla_policies(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Helpdesk.match_sla_policies/2")
    end
  end
end
