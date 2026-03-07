defmodule UniboExPoc.Ecommerce.Changes.ProductPrice.UpdateCall1 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Ecommerce, :recompute_prices, 2) do
      Ecommerce.recompute_prices(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Ecommerce.recompute_prices/2")
    end
  end
end
