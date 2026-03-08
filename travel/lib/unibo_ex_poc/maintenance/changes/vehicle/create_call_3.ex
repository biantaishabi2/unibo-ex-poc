defmodule UniboExPoc.Maintenance.Changes.Vehicle.CreateCall3 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Maintenance, :create_driver_history, 2) do
      Maintenance.create_driver_history(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Maintenance.create_driver_history/2")
    end
  end
end
