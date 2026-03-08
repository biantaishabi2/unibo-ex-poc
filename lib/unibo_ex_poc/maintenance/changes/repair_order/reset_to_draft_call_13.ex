defmodule UniboV4.Maintenance.Changes.RepairOrder.ResetToDraftCall13 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Maintenance, :restore_sale_order_line, 2) do
      Maintenance.restore_sale_order_line(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Maintenance.restore_sale_order_line/2")
    end
  end
end
