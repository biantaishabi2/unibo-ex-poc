defmodule UniboV4.Website.Changes.WebSite.CreateCall1 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Website, :auto_create_homepage, 2) do
      Website.auto_create_homepage(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Website.auto_create_homepage/2")
    end
  end
end
