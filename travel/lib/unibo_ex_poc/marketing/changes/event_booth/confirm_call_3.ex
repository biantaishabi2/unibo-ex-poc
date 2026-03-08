defmodule UniboExPoc.Marketing.Changes.EventBooth.ConfirmCall3 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Marketing, :sync_contact_from_partner, 2) do
      Marketing.sync_contact_from_partner(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Marketing.sync_contact_from_partner/2")
    end
  end
end
