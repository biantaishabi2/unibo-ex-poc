defmodule UniboV4.POS.Changes.PosPayment.CreateCall1 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(POS, :route_accounting, 2) do
      POS.route_accounting(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: POS.route_accounting/2")
    end
  end
end
