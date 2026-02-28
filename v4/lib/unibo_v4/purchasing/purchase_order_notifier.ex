defmodule UniboV4.Purchasing.PurchaseOrder.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :submit -> "purchasing.order.submitted"
      :approve -> "purchasing.order.approved"
      :reject -> "purchasing.order.rejected"
      :receive -> "purchasing.order.received"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
