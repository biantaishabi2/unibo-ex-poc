defmodule UniboExPoc.Maintenance.Changes.RepairOrder.StartRepairCall16 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Maintenance, :propagate_locations, 2) do
      Maintenance.propagate_locations(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Maintenance.propagate_locations/2")
    end
  end
end
