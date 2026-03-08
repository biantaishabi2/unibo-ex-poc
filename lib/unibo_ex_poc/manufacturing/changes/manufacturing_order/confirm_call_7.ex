defmodule UniboV4.Manufacturing.Changes.ManufacturingOrder.ConfirmCall7 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(stock.move, :adjust_procure_method, 2) do
      stock.move.adjust_procure_method(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: stock.move.adjust_procure_method/2")
    end
  end
end
