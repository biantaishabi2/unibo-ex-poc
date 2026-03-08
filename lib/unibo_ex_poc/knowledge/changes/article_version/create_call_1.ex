defmodule UniboV4.Knowledge.Changes.ArticleVersion.CreateCall1 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Knowledge, :auto_number_version, 2) do
      Knowledge.auto_number_version(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Knowledge.auto_number_version/2")
    end
  end
end
