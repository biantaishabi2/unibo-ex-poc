defmodule UniboExPoc.Inventory.Changes.StockPicking.ButtonValidateCall3 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(MoveIds, :action_done, 2) do
      MoveIds.action_done(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: MoveIds.action_done/2")
    end
  end
end
