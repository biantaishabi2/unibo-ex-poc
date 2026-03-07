defmodule UniboExPoc.Website.Changes.WebSite.CreateCall5 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Website, :scale_favicon, 2) do
      Website.scale_favicon(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Website.scale_favicon/2")
    end
  end
end
