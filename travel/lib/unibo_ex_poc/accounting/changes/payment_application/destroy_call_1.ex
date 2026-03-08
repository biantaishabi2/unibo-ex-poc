defmodule UniboExPoc.Accounting.Changes.PaymentApplication.DestroyCall1 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Accounting, :recompute_invoice_paid_amount, 2) do
      Accounting.recompute_invoice_paid_amount(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Accounting.recompute_invoice_paid_amount/2")
    end
  end
end
