defmodule UniboV4.POS.Changes.PosSession.CloseCall11 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(POS, :create_stock_pickings, 2) do
      POS.create_stock_pickings(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: POS.create_stock_pickings/2")
    end
  end
end
