defmodule UniboV4.POS.Changes.PosSession.CloseCall8 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(POS, :create_account_payments, 2) do
      POS.create_account_payments(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: POS.create_account_payments/2")
    end
  end
end
