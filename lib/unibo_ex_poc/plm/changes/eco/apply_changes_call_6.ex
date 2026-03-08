defmodule UniboV4.PLM.Changes.Eco.ApplyChangesCall6 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(PLM, :update_draft_manufacturing_orders, 2) do
      PLM.update_draft_manufacturing_orders(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: PLM.update_draft_manufacturing_orders/2")
    end
  end
end
