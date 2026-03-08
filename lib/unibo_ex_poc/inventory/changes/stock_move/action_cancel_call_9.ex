defmodule UniboV4.Inventory.Changes.StockMove.ActionCancelCall9 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(MoveLineIds, :release_reservation, 2) do
      MoveLineIds.release_reservation(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: MoveLineIds.release_reservation/2")
    end
  end
end
