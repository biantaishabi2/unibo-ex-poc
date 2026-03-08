defmodule UniboExPoc.Maintenance.Changes.RepairOrder.ConfirmCall15 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Maintenance, :warranty_pricing, 2) do
      Maintenance.warranty_pricing(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Maintenance.warranty_pricing/2")
    end
  end
end
