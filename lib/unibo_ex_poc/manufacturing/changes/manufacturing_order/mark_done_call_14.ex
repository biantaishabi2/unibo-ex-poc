defmodule UniboV4.Manufacturing.Changes.ManufacturingOrder.MarkDoneCall14 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Manufacturing, :prepare_finished_extra_vals, 2) do
      Manufacturing.prepare_finished_extra_vals(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Manufacturing.prepare_finished_extra_vals/2")
    end
  end
end
