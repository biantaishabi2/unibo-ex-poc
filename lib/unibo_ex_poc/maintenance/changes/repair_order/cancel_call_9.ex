defmodule UniboV4.Maintenance.Changes.RepairOrder.CancelCall9 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Maintenance, :cancel_all_stock_moves, 2) do
      Maintenance.cancel_all_stock_moves(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Maintenance.cancel_all_stock_moves/2")
    end
  end
end
