defmodule UniboExPoc.Knowledge.Changes.Article.ActionArchiveCall17 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Knowledge, :recursive_archive_descendants, 2) do
      Knowledge.recursive_archive_descendants(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Knowledge.recursive_archive_descendants/2")
    end
  end
end
