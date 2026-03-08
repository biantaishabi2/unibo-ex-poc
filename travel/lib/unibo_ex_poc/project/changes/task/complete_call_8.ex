defmodule UniboExPoc.Project.Changes.Task.CompleteCall8 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Project, :send_rating_request, 2) do
      Project.send_rating_request(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Project.send_rating_request/2")
    end
  end
end
