defmodule UniboV4.Helpdesk.Changes.HelpdeskTicket.CreateCall14 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Helpdesk, :set_source_channel, 2) do
      Helpdesk.set_source_channel(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Helpdesk.set_source_channel/2")
    end
  end
end
