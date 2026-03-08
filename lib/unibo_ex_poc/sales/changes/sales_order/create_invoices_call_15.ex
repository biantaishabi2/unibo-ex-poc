defmodule UniboV4.Sales.Changes.SalesOrder.CreateInvoicesCall15 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Sales, :convert_to_refund, 2) do
      Sales.convert_to_refund(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Sales.convert_to_refund/2")
    end
  end
end
