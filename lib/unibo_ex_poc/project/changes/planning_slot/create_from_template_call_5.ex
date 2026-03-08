defmodule UniboV4.Project.Changes.PlanningSlot.CreateFromTemplateCall5 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Project, :copy_from_template, 2) do
      Project.copy_from_template(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Project.copy_from_template/2")
    end
  end
end
