defmodule UniboExPoc.CRM.Changes.SalesTeamMember.CreateCall1 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(CRM, :synchronize_memberships, 2) do
      CRM.synchronize_memberships(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: CRM.synchronize_memberships/2")
    end
  end
end
