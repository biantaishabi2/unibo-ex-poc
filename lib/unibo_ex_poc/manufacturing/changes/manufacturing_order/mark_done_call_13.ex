defmodule UniboV4.Manufacturing.Changes.ManufacturingOrder.MarkDoneCall13 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Manufacturing, :set_finished_moves_picked, 2) do
      Manufacturing.set_finished_moves_picked(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Manufacturing.set_finished_moves_picked/2")
    end
  end
end
