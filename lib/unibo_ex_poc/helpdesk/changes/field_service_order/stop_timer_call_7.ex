defmodule UniboV4.Helpdesk.Changes.FieldServiceOrder.StopTimerCall7 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Helpdesk, :create_timesheet_entry, 2) do
      Helpdesk.create_timesheet_entry(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Helpdesk.create_timesheet_entry/2")
    end
  end
end
