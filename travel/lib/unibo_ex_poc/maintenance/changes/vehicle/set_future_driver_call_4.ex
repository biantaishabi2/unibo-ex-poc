defmodule UniboExPoc.Maintenance.Changes.Vehicle.SetFutureDriverCall4 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Maintenance, :set_plan_to_change, 2) do
      Maintenance.set_plan_to_change(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Maintenance.set_plan_to_change/2")
    end
  end
end
