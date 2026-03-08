defmodule UniboV4.Communication.Changes.Message.CreateCall6 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Communication, :extract_voice_metadata, 2) do
      Communication.extract_voice_metadata(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Communication.extract_voice_metadata/2")
    end
  end
end
