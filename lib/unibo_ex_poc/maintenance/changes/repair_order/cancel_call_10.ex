defmodule UniboV4.Maintenance.Changes.RepairOrder.CancelCall10 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Maintenance, :zero_sale_order_line, 2) do
      Maintenance.zero_sale_order_line(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Maintenance.zero_sale_order_line/2")
    end
  end
end
