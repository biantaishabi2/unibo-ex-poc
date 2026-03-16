defmodule UniboExPoc.Travel.TravelRefundOrder.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :approve -> "travel.refund_order.approved"
      :reject -> "travel.refund_order.rejected"
      :refund -> "travel.refund_order.refunded"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboExPoc.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
