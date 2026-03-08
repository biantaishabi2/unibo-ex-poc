defmodule UniboV4.Project.Changes.Project.ArchiveCall6 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Project, :sync_stage_to_company, 2) do
      Project.sync_stage_to_company(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Project.sync_stage_to_company/2")
    end
  end
end
