defmodule UniboV4.POS.Changes.RestaurantFloor.DeactivateCall2 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(POS, :deactivate_tables, 2) do
      POS.deactivate_tables(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: POS.deactivate_tables/2")
    end
  end
end
