defmodule UniboV4.Website.Changes.Menu.CreateCall3 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Website, :reassign_parent, 2) do
      Website.reassign_parent(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Website.reassign_parent/2")
    end
  end
end
