defmodule UniboV4.Accounting.Changes.Payment.PostCall3 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Accounting, :generate_payment_lines, 2) do
      Accounting.generate_payment_lines(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Accounting.generate_payment_lines/2")
    end
  end
end
