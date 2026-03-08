defmodule UniboExPoc.Rental.Changes.RentalOrderLine.UpdateCall8 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Rental, :recompute_rental_price, 2) do
      Rental.recompute_rental_price(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Rental.recompute_rental_price/2")
    end
  end
end
