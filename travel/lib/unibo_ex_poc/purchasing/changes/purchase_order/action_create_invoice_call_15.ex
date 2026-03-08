defmodule UniboExPoc.Purchasing.Changes.PurchaseOrder.ActionCreateInvoiceCall15 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(account, :switch_move_type_if_negative, 2) do
      account.switch_move_type_if_negative(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: account.switch_move_type_if_negative/2")
    end
  end
end
