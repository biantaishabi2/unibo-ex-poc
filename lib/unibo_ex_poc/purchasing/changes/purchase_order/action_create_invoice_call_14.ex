defmodule UniboV4.Purchasing.Changes.PurchaseOrder.ActionCreateInvoiceCall14 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(account, :create_invoice, 2) do
      account.create_invoice(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: account.create_invoice/2")
    end
  end
end
