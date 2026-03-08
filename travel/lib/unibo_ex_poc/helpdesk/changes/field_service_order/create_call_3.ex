defmodule UniboExPoc.Helpdesk.Changes.FieldServiceOrder.CreateCall3 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Helpdesk, :increment_ticket_task_count, 2) do
      Helpdesk.increment_ticket_task_count(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Helpdesk.increment_ticket_task_count/2")
    end
  end
end
