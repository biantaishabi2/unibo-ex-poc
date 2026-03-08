defmodule UniboExPoc.CRM.Changes.Contact.UpdateCall1 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(CRM, :track_field_change, 2) do
      CRM.track_field_change(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: CRM.track_field_change/2")
    end
  end
end
