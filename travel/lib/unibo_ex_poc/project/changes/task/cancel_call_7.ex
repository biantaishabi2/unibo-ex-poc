defmodule UniboExPoc.Project.Changes.Task.CancelCall7 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Project, :create_next_recurrence, 2) do
      Project.create_next_recurrence(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Project.create_next_recurrence/2")
    end
  end
end
