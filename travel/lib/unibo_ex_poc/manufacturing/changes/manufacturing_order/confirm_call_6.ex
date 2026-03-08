defmodule UniboExPoc.Manufacturing.Changes.ManufacturingOrder.ConfirmCall6 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(stock.move, :action_confirm, 2) do
      stock.move.action_confirm(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: stock.move.action_confirm/2")
    end
  end
end
