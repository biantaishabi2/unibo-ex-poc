defmodule UniboExPoc.Maintenance.Changes.RepairOrder.ResetToDraftCall12 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Maintenance, :reset_stock_moves, 2) do
      Maintenance.reset_stock_moves(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Maintenance.reset_stock_moves/2")
    end
  end
end
