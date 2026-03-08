defmodule UniboExPoc.PLM.Changes.Eco.ApplyChangesCall7 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(PLM, :advance_to_effective, 2) do
      PLM.advance_to_effective(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: PLM.advance_to_effective/2")
    end
  end
end
