defmodule UniboV4.Ecommerce.Changes.ShoppingCart.UpdatePricelistCall6 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Ecommerce, :recompute_all_line_prices, 2) do
      Ecommerce.recompute_all_line_prices(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Ecommerce.recompute_all_line_prices/2")
    end
  end
end
