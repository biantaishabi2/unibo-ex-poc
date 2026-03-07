defmodule UniboExPoc.Website.Changes.Menu.CreateCall4 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Website, :invalidate_menu_cache, 2) do
      Website.invalidate_menu_cache(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Website.invalidate_menu_cache/2")
    end
  end
end
