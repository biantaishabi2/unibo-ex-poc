defmodule UniboExPoc.Purchasing.Changes.PurchaseOrder.ButtonConfirmCall12 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(product, :add_supplier_to_product, 2) do
      product.add_supplier_to_product(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: product.add_supplier_to_product/2")
    end
  end
end
