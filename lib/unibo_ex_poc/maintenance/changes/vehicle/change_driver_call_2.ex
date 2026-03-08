defmodule UniboV4.Maintenance.Changes.Vehicle.ChangeDriverCall2 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Maintenance, :create_assignment_log, 2) do
      Maintenance.create_assignment_log(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Maintenance.create_assignment_log/2")
    end
  end
end
