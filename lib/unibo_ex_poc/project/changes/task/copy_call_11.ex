defmodule UniboV4.Project.Changes.Task.CopyCall11 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Project, :deep_copy, 2) do
      Project.deep_copy(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Project.deep_copy/2")
    end
  end
end
