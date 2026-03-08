defmodule UniboExPoc.Marketing.Changes.EventMailSchedule.UpdateCall1 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Marketing, :reset_mail_done, 2) do
      Marketing.reset_mail_done(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Marketing.reset_mail_done/2")
    end
  end
end
