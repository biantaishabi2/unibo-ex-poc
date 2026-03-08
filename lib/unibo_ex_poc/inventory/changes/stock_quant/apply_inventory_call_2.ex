defmodule UniboV4.Inventory.Changes.StockQuant.ApplyInventoryCall2 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Inventory, :invoke, 2) do
      Inventory.invoke(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Inventory.invoke/2")
    end
  end
end
