defmodule UniboV4.Website.Changes.Menu.UpdateCall1 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Website, :clean_url, 2) do
      Website.clean_url(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Website.clean_url/2")
    end
  end
end
