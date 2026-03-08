defmodule UniboV4.POS.Changes.PosOrder.PayCall5 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(POS, :process_payment_lines, 2) do
      POS.process_payment_lines(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: POS.process_payment_lines/2")
    end
  end
end
