defmodule UniboV4.Manufacturing.Changes.ManufacturingOrder.MarkDoneCall12 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Manufacturing, :update_finished_move_qty, 2) do
      Manufacturing.update_finished_move_qty(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Manufacturing.update_finished_move_qty/2")
    end
  end
end
