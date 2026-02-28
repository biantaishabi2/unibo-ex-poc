defmodule UniboV4.Sales.SalesOrder.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :confirm -> "sales.order.confirmed"
      :ship -> "sales.order.shipped"
      :deliver -> "sales.order.delivered"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
