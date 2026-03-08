defmodule UniboV4.POS.Changes.PosSession.CloseCall12 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(POS, :create_profit_loss_statement_line, 2) do
      POS.create_profit_loss_statement_line(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: POS.create_profit_loss_statement_line/2")
    end
  end
end
