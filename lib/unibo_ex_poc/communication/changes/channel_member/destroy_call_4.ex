defmodule UniboV4.Communication.Changes.ChannelMember.DestroyCall4 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Communication, :broadcast_event, 2) do
      Communication.broadcast_event(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Communication.broadcast_event/2")
    end
  end
end
