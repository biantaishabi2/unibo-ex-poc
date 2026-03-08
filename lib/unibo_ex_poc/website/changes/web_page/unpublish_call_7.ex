defmodule UniboV4.Website.Changes.WebPage.UnpublishCall7 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Website, :cow_branch, 2) do
      Website.cow_branch(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Website.cow_branch/2")
    end
  end
end
