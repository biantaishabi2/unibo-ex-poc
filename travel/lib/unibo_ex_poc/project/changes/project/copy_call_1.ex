defmodule UniboExPoc.Project.Changes.Project.CopyCall1 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Project, :auto_assign, 2) do
      Project.auto_assign(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Project.auto_assign/2")
    end
  end
end
