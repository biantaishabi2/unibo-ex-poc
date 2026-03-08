defmodule UniboV4.Inventory.Changes.StockMove.ActionDoneCall6 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(StockQuant, :update_available_quantity, 2) do
      StockQuant.update_available_quantity(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: StockQuant.update_available_quantity/2")
    end
  end
end
