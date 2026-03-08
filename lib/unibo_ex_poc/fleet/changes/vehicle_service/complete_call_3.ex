defmodule UniboV4.Fleet.Changes.VehicleService.CompleteCall3 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Fleet, :set_related, 2) do
      Fleet.set_related(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Fleet.set_related/2")
    end
  end
end
