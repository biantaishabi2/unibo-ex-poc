defmodule UniboV4.Maintenance.Changes.MaintenanceRequest.ChangeStageCall8 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Maintenance, :clone_preventive, 2) do
      Maintenance.clone_preventive(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Maintenance.clone_preventive/2")
    end
  end
end
