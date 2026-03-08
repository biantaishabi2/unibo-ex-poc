defmodule UniboV4.Marketing.Changes.MailingList.MergeCall1 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Marketing, :deduplicate_by_email, 2) do
      Marketing.deduplicate_by_email(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Marketing.deduplicate_by_email/2")
    end
  end
end
