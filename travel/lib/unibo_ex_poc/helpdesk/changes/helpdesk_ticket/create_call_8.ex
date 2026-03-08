defmodule UniboExPoc.Helpdesk.Changes.HelpdeskTicket.CreateCall8 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Helpdesk, :auto_assign_by_method, 2) do
      Helpdesk.auto_assign_by_method(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Helpdesk.auto_assign_by_method/2")
    end
  end
end
