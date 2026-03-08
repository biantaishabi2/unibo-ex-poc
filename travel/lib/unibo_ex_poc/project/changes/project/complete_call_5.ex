defmodule UniboExPoc.Project.Changes.Project.CompleteCall5 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Project, :subscribe_partner, 2) do
      Project.subscribe_partner(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Project.subscribe_partner/2")
    end
  end
end
