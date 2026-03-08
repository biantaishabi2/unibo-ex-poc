defmodule UniboV4.POS.Changes.PosSession.CloseCall10 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(POS, :reconcile_accounts, 2) do
      POS.reconcile_accounts(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: POS.reconcile_accounts/2")
    end
  end
end
