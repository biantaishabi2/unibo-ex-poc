defmodule UniboV4.Rental.Changes.RentalOrderLine.ValidateReturnCall7 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Rental, :compute_penalty, 2) do
      Rental.compute_penalty(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Rental.compute_penalty/2")
    end
  end
end
