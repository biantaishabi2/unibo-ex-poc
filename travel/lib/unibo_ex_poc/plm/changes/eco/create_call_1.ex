defmodule UniboExPoc.PLM.Changes.Eco.CreateCall1 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(PLM, :copy_bom_as_revision, 2) do
      PLM.copy_bom_as_revision(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: PLM.copy_bom_as_revision/2")
    end
  end
end
