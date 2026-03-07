defmodule UniboExPoc.Ecommerce.Changes.ShoppingCart.CartUpdateCall7 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Ecommerce, :update_session_quantity, 2) do
      Ecommerce.update_session_quantity(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Ecommerce.update_session_quantity/2")
    end
  end
end
