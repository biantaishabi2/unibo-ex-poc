defmodule UniboExPoc.Maintenance.Changes.RepairOrder.ConfirmCall2 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Maintenance, :confirm_stock_moves, 2) do
      Maintenance.confirm_stock_moves(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Maintenance.confirm_stock_moves/2")
    end
  end
end
