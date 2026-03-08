defmodule UniboV4.Website.Changes.WebPage.UnpublishCall3 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Website, :slugify_url, 2) do
      Website.slugify_url(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Website.slugify_url/2")
    end
  end
end
