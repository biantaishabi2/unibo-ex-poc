defmodule UniboExPoc.Helpdesk.Changes.HelpdeskTicket.CloseCall12 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Helpdesk, :send_rating_request, 2) do
      Helpdesk.send_rating_request(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Helpdesk.send_rating_request/2")
    end
  end
end
