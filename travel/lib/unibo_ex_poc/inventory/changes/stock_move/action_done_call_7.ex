defmodule UniboExPoc.Inventory.Changes.StockMove.ActionDoneCall7 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(MoveDestIds, :trigger_assign, 2) do
      MoveDestIds.trigger_assign(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: MoveDestIds.trigger_assign/2")
    end
  end
end
