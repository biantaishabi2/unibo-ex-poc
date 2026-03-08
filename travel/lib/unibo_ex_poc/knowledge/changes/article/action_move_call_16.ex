defmodule UniboExPoc.Knowledge.Changes.Article.ActionMoveCall16 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Knowledge, :inherit_parent_category, 2) do
      Knowledge.inherit_parent_category(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Knowledge.inherit_parent_category/2")
    end
  end
end
