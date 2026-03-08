defmodule UniboExPoc.Accounting.Changes.Payment.PostCall6 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Accounting, :create_paired_internal_transfer, 2) do
      Accounting.create_paired_internal_transfer(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Accounting.create_paired_internal_transfer/2")
    end
  end
end
