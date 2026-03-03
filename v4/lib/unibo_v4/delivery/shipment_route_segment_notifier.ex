defmodule UniboV4.Delivery.Delivery.ShipmentRouteSegment.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :update_tracking -> "delivery.tracking.updated"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboV4.Delivery.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
