defmodule UniboV4.Knowledge.Changes.Article.ActionRestoreTrashCall19 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Knowledge, :restore_trash_reparent, 2) do
      Knowledge.restore_trash_reparent(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Knowledge.restore_trash_reparent/2")
    end
  end
end
