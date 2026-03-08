defmodule UniboExPoc.Maintenance.Changes.MaintenanceRequest.CancelCall9 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Maintenance, :manage_activity, 2) do
      Maintenance.manage_activity(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Maintenance.manage_activity/2")
    end
  end
end
