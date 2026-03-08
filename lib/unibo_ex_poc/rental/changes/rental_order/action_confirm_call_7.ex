defmodule UniboV4.Rental.Changes.RentalOrder.ActionConfirmCall7 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Rental, :create_stock_pickings, 2) do
      Rental.create_stock_pickings(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Rental.create_stock_pickings/2")
    end
  end
end
