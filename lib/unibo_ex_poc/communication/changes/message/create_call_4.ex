defmodule UniboV4.Communication.Changes.Message.CreateCall4 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Communication, :auto_mark_read, 2) do
      Communication.auto_mark_read(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Communication.auto_mark_read/2")
    end
  end
end
