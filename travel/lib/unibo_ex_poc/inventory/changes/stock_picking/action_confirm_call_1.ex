defmodule UniboExPoc.Inventory.Changes.StockPicking.ActionConfirmCall1 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(MoveIds, :action_confirm, 2) do
      MoveIds.action_confirm(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: MoveIds.action_confirm/2")
    end
  end
end
