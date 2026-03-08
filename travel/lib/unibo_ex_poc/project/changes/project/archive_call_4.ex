defmodule UniboExPoc.Project.Changes.Project.ArchiveCall4 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Project, :unsubscribe_portal_users, 2) do
      Project.unsubscribe_portal_users(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Project.unsubscribe_portal_users/2")
    end
  end
end
