defmodule UniboV4.Marketing.Changes.EventBooth.ConfirmCall4 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Marketing, :post_confirmation_message, 2) do
      Marketing.post_confirmation_message(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Marketing.post_confirmation_message/2")
    end
  end
end
