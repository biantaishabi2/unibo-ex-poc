defmodule UniboExPoc.Project.Changes.PlanningSlot.PublishCall3 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Project, :send_notification, 2) do
      Project.send_notification(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Project.send_notification/2")
    end
  end
end
