defmodule UniboV4.POS.Changes.PosSession.CloseCall7 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(POS, :create_account_moves, 2) do
      POS.create_account_moves(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: POS.create_account_moves/2")
    end
  end
end
