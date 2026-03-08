defmodule UniboV4.Maintenance.Changes.ServiceLog.CreateCall5 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Maintenance, :compute_purchaser, 2) do
      Maintenance.compute_purchaser(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Maintenance.compute_purchaser/2")
    end
  end
end
