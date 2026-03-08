defmodule UniboV4.Ecommerce.Changes.ShoppingCart.CartUpdateCall5 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Ecommerce, :remove_delivery_lines, 2) do
      Ecommerce.remove_delivery_lines(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Ecommerce.remove_delivery_lines/2")
    end
  end
end
