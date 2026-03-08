defmodule UniboExPoc.Accounting.Changes.FullReconcile.CreateCall1 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Accounting, :recompute_payment_state, 2) do
      Accounting.recompute_payment_state(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Accounting.recompute_payment_state/2")
    end
  end
end
