defmodule UniboV4.Manufacturing.Changes.ManufacturingOrder.ConfirmCall10 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(stock.picking, :action_confirm, 2) do
      stock.picking.action_confirm(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: stock.picking.action_confirm/2")
    end
  end
end
