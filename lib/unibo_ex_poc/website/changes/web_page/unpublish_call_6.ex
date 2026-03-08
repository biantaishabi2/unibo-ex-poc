defmodule UniboV4.Website.Changes.WebPage.UnpublishCall6 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Website, :sync_homepage, 2) do
      Website.sync_homepage(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Website.sync_homepage/2")
    end
  end
end
