defmodule UniboV4.Project.Changes.Task.CreateCall14 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Project, :portal_access_check, 2) do
      Project.portal_access_check(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Project.portal_access_check/2")
    end
  end
end
