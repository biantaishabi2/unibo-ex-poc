defmodule UniboV4.Helpdesk.Changes.HelpdeskTicket.ChangeStageCall13 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Helpdesk, :send_stage_notification, 2) do
      Helpdesk.send_stage_notification(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Helpdesk.send_stage_notification/2")
    end
  end
end
