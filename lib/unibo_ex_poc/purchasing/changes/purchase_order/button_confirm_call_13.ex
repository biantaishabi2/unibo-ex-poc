defmodule UniboV4.Purchasing.Changes.PurchaseOrder.ButtonConfirmCall13 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(mail, :message_subscribe, 2) do
      mail.message_subscribe(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: mail.message_subscribe/2")
    end
  end
end
