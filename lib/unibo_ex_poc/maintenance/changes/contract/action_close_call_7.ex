defmodule UniboV4.Maintenance.Changes.Contract.ActionCloseCall7 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Maintenance, :reschedule_renewal_activity, 2) do
      Maintenance.reschedule_renewal_activity(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Maintenance.reschedule_renewal_activity/2")
    end
  end
end
