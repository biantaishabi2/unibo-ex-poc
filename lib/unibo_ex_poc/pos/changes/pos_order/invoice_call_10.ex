defmodule UniboV4.POS.Changes.PosOrder.InvoiceCall10 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(POS, :create_reversal_move, 2) do
      POS.create_reversal_move(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: POS.create_reversal_move/2")
    end
  end
end
