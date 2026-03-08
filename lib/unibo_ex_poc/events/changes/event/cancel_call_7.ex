defmodule UniboV4.Events.Changes.Event.CancelCall7 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Events, :notify_registrants, 2) do
      Events.notify_registrants(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Events.notify_registrants/2")
    end
  end
end
