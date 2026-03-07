defmodule UniboExPoc.Sales.SalesOrder.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :action_quotation_send -> "sales.order.sent"
      :action_confirm -> "sales.order.confirmed"
      :action_done -> "sales.order.done"
      :action_cancel -> "sales.order.cancelled"
      :action_draft -> "sales.order.reset_to_draft"
      :create_invoices -> "sales.order.invoice_created"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboExPoc.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
