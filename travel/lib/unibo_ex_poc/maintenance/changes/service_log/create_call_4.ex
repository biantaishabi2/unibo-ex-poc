defmodule UniboExPoc.Maintenance.Changes.ServiceLog.CreateCall4 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Maintenance, :append_odometer, 2) do
      Maintenance.append_odometer(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Maintenance.append_odometer/2")
    end
  end
end
