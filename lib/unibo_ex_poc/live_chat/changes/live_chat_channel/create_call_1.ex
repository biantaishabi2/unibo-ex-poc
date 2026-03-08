defmodule UniboV4.LiveChat.Changes.LiveChatChannel.CreateCall1 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(LiveChat, :add_relation, 2) do
      LiveChat.add_relation(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: LiveChat.add_relation/2")
    end
  end
end
