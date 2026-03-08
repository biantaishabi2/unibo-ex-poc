defmodule UniboV4.Manufacturing.Changes.ManufacturingOrder.ConfirmCall9 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(stock.move, :trigger_scheduler, 2) do
      stock.move.trigger_scheduler(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: stock.move.trigger_scheduler/2")
    end
  end
end
