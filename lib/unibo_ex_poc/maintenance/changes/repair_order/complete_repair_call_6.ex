defmodule UniboV4.Maintenance.Changes.RepairOrder.CompleteRepairCall6 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Maintenance, :create_product_move, 2) do
      Maintenance.create_product_move(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Maintenance.create_product_move/2")
    end
  end
end
