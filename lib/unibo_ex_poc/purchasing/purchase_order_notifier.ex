defmodule UniboExPoc.Purchasing.PurchaseOrder.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :button_confirm -> "purchasing.order.confirmed"
      :button_approve -> "purchasing.order.approved"
      :button_cancel -> "purchasing.order.cancelled"
      :button_done -> "purchasing.order.locked"
      :button_unlock -> "purchasing.order.unlocked"
      :button_draft -> "purchasing.order.reset_to_draft"
      :action_create_invoice -> "purchasing.order.invoice_created"
      :print_quotation -> "purchasing.order.rfq_printed"
      :send_rfq -> "purchasing.order.rfq_sent"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboExPoc.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
