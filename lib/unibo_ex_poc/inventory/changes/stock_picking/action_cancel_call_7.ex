defmodule UniboV4.Inventory.Changes.StockPicking.ActionCancelCall7 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(MoveIds, :action_cancel, 2) do
      MoveIds.action_cancel(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: MoveIds.action_cancel/2")
    end
  end
end
