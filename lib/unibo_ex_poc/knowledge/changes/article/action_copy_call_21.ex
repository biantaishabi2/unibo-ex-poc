defmodule UniboV4.Knowledge.Changes.Article.ActionCopyCall21 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Knowledge, :deep_copy_article, 2) do
      Knowledge.deep_copy_article(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Knowledge.deep_copy_article/2")
    end
  end
end
