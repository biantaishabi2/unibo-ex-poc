defmodule UniboExPoc.POS.Changes.PosOrder.PayCall4 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(POS, :clean_payment_lines, 2) do
      POS.clean_payment_lines(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: POS.clean_payment_lines/2")
    end
  end
end
