defmodule UniboV4.Manufacturing.Changes.ManufacturingOrder.MarkDoneCall17 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Manufacturing, :link_consume_to_finished, 2) do
      Manufacturing.link_consume_to_finished(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Manufacturing.link_consume_to_finished/2")
    end
  end
end
