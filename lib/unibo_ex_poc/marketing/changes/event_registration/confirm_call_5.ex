defmodule UniboV4.Marketing.Changes.EventRegistration.ConfirmCall5 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Marketing, :trigger_after_sub_mails, 2) do
      Marketing.trigger_after_sub_mails(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Marketing.trigger_after_sub_mails/2")
    end
  end
end
