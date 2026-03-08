defmodule UniboV4.Marketing.Changes.Mailing.PutInQueueCall6 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Marketing, :generate_unsubscribe_token, 2) do
      Marketing.generate_unsubscribe_token(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Marketing.generate_unsubscribe_token/2")
    end
  end
end
