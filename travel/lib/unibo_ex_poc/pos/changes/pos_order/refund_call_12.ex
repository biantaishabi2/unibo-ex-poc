defmodule UniboExPoc.POS.Changes.PosOrder.RefundCall12 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(POS, :create_refund_order, 2) do
      POS.create_refund_order(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: POS.create_refund_order/2")
    end
  end
end
