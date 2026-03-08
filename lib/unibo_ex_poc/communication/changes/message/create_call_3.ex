defmodule UniboV4.Communication.Changes.Message.CreateCall3 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Communication, :update_all_channel_members, 2) do
      Communication.update_all_channel_members(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Communication.update_all_channel_members/2")
    end
  end
end
