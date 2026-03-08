defmodule UniboExPoc.Maintenance.Changes.MaintenanceRequest.CreateCall4 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Maintenance, :subscribe_followers, 2) do
      Maintenance.subscribe_followers(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Maintenance.subscribe_followers/2")
    end
  end
end
