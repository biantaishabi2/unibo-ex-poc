defmodule UniboExPoc.Manufacturing.Changes.ManufacturingOrder.MarkDoneCall15 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Manufacturing, :record_workorder_duration, 2) do
      Manufacturing.record_workorder_duration(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Manufacturing.record_workorder_duration/2")
    end
  end
end
