defmodule UniboExPoc.PLM.Changes.Eco.RebaseCall8 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(PLM, :rebase_bom, 2) do
      PLM.rebase_bom(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: PLM.rebase_bom/2")
    end
  end
end
