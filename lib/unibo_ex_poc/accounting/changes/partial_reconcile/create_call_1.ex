defmodule UniboV4.Accounting.Changes.PartialReconcile.CreateCall1 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Accounting, :reduce_residual, 2) do
      Accounting.reduce_residual(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Accounting.reduce_residual/2")
    end
  end
end
