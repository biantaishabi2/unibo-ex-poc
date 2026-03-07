defmodule UniboExPoc.Website.Changes.WebPage.PublishCall5 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Website, :sync_menu_url, 2) do
      Website.sync_menu_url(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Website.sync_menu_url/2")
    end
  end
end
