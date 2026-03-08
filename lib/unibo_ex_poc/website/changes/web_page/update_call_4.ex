defmodule UniboV4.Website.Changes.WebPage.UpdateCall4 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Website, :create_redirect, 2) do
      Website.create_redirect(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Website.create_redirect/2")
    end
  end
end
