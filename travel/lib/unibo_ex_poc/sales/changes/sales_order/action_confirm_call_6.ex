defmodule UniboExPoc.Sales.Changes.SalesOrder.ActionConfirmCall6 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Sales, :subscribe_partner, 2) do
      Sales.subscribe_partner(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Sales.subscribe_partner/2")
    end
  end
end
