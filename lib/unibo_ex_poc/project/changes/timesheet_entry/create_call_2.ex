defmodule UniboV4.Project.Changes.TimesheetEntry.CreateCall2 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Project, :auto_resolve, 2) do
      Project.auto_resolve(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Project.auto_resolve/2")
    end
  end
end
