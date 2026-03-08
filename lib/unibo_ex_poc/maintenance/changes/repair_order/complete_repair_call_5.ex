defmodule UniboV4.Maintenance.Changes.RepairOrder.CompleteRepairCall5 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Maintenance, :cancel_zero_qty_moves, 2) do
      Maintenance.cancel_zero_qty_moves(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Maintenance.cancel_zero_qty_moves/2")
    end
  end
end
