defmodule UniboExPoc.Communication.Changes.Message.CreateCall1 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Communication, :generate, 2) do
      Communication.generate(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Communication.generate/2")
    end
  end
end
