defmodule UniboV4.Knowledge.Changes.Article.ActionArchiveCall20 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Knowledge, :create_version_snapshot, 2) do
      Knowledge.create_version_snapshot(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Knowledge.create_version_snapshot/2")
    end
  end
end
