defmodule UniboV4.Knowledge.Changes.Article.ActionTrashCall18 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Knowledge, :recursive_trash_descendants, 2) do
      Knowledge.recursive_trash_descendants(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Knowledge.recursive_trash_descendants/2")
    end
  end
end
