defmodule UniboExPoc.Helpdesk.Changes.FieldServiceOrder.MarkDoneCall4 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Helpdesk, :check_all_tasks_done, 2) do
      Helpdesk.check_all_tasks_done(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Helpdesk.check_all_tasks_done/2")
    end
  end
end
