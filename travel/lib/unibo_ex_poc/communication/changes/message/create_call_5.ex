defmodule UniboExPoc.Communication.Changes.Message.CreateCall5 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Communication, :sudo_execute, 2) do
      Communication.sudo_execute(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Communication.sudo_execute/2")
    end
  end
end
