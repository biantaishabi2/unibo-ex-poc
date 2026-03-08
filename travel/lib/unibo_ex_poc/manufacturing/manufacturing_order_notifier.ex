defmodule UniboExPoc.Manufacturing.ManufacturingOrder.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :mark_done -> "manufacturing.order.completed"
      :complete -> "manufacturing.order.completed"
      :confirm -> "manufacturing.order.confirmed"
      :split_production -> "manufacturing.order.backorder_created"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboExPoc.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
