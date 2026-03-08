defmodule UniboExPoc.Project.Changes.PlanningSlot.PublishCall2 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Project, :associate, 2) do
      Project.associate(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Project.associate/2")
    end
  end
end
