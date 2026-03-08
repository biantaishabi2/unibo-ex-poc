defmodule UniboV4.Manufacturing.Changes.ManufacturingOrder.MarkDoneCall11 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Manufacturing, :skip_done_moves, 2) do
      Manufacturing.skip_done_moves(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Manufacturing.skip_done_moves/2")
    end
  end
end
