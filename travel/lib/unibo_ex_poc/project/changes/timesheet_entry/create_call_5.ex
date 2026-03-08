defmodule UniboExPoc.Project.Changes.TimesheetEntry.CreateCall5 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Project, :compute_encoding_uom, 2) do
      Project.compute_encoding_uom(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Project.compute_encoding_uom/2")
    end
  end
end
