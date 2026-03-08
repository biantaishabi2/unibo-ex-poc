defmodule UniboExPoc.POS.Changes.PosOrder.InvoiceCall9 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(POS, :create_invoice, 2) do
      POS.create_invoice(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: POS.create_invoice/2")
    end
  end
end
