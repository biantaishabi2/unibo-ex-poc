defmodule UniboExPoc.Maintenance.Changes.Vehicle.SetOdometerCall1 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Maintenance, :compute_model_fields, 2) do
      Maintenance.compute_model_fields(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Maintenance.compute_model_fields/2")
    end
  end
end
