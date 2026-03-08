defmodule UniboV4.PLM.Changes.Eco.CreateCall2 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(PLM, :set_default_stage, 2) do
      PLM.set_default_stage(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: PLM.set_default_stage/2")
    end
  end
end
