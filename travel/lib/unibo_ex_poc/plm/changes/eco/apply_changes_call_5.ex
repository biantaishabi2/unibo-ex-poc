defmodule UniboExPoc.PLM.Changes.Eco.ApplyChangesCall5 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(PLM, :apply_bom_changes, 2) do
      PLM.apply_bom_changes(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: PLM.apply_bom_changes/2")
    end
  end
end
