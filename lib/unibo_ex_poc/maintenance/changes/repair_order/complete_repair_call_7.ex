defmodule UniboV4.Maintenance.Changes.RepairOrder.CompleteRepairCall7 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Maintenance, :action_done_stock, 2) do
      Maintenance.action_done_stock(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Maintenance.action_done_stock/2")
    end
  end
end
