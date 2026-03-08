defmodule UniboV4.Marketing.Changes.EventRegistration.ConfirmCall6 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Marketing, :auto_create_partner, 2) do
      Marketing.auto_create_partner(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Marketing.auto_create_partner/2")
    end
  end
end
