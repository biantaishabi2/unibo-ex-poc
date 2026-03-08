defmodule UniboExPoc.Project.Changes.Task.AssignCall13 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Project, :parse_display_name, 2) do
      Project.parse_display_name(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Project.parse_display_name/2")
    end
  end
end
