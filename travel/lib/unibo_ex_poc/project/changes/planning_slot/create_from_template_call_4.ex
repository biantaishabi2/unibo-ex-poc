defmodule UniboExPoc.Project.Changes.PlanningSlot.CreateFromTemplateCall4 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Project, :generate_recurrence, 2) do
      Project.generate_recurrence(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Project.generate_recurrence/2")
    end
  end
end
