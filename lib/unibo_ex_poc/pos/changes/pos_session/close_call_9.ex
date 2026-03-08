defmodule UniboV4.POS.Changes.PosSession.CloseCall9 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(POS, :create_bank_statement_lines, 2) do
      POS.create_bank_statement_lines(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: POS.create_bank_statement_lines/2")
    end
  end
end
