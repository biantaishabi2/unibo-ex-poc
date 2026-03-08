defmodule UniboV4.Quality.Changes.QualityAlert.CreateMaintenanceRequestCall7 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(maintenance, :create_maintenance_request, 2) do
      maintenance.create_maintenance_request(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: maintenance.create_maintenance_request/2")
    end
  end
end
