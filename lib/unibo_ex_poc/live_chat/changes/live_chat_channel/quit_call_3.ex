defmodule UniboV4.LiveChat.Changes.LiveChatChannel.QuitCall3 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(LiveChat, :remove_relation, 2) do
      LiveChat.remove_relation(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: LiveChat.remove_relation/2")
    end
  end
end
