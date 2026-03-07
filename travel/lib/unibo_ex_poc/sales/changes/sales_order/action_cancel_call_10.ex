defmodule UniboExPoc.Sales.Changes.SalesOrder.ActionCancelCall10 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Sales, :cancel_related, 2) do
      Sales.cancel_related(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Sales.cancel_related/2")
    end
  end
end
