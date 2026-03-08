defmodule UniboV4.Maintenance.Changes.RepairOrder.CompleteRepairCall8 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Maintenance, :sync_qty_delivered, 2) do
      Maintenance.sync_qty_delivered(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Maintenance.sync_qty_delivered/2")
    end
  end
end
