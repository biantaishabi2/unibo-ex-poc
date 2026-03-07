defmodule UniboExPoc.Website.Changes.WebSite.CreateCall2 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Website, :auto_create_public_user, 2) do
      Website.auto_create_public_user(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Website.auto_create_public_user/2")
    end
  end
end
