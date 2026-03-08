defmodule UniboExPoc.LiveChat.Changes.ChatSession.CreateCall1 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(livechat_channel, :assign_operator, 2) do
      livechat_channel.assign_operator(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: livechat_channel.assign_operator/2")
    end
  end
end
