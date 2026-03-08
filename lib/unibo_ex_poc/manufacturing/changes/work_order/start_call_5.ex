defmodule UniboV4.Manufacturing.Changes.WorkOrder.StartCall5 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(resource.calendar, :leaves, 2) do
      resource.calendar.leaves(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: resource.calendar.leaves/2")
    end
  end
end
