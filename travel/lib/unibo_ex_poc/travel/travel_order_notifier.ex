defmodule UniboExPoc.Travel.Travel.TravelOrder.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :submit_order -> "travel.order.submitted"
      :mark_payment_succeeded -> "travel.order.payment_confirmed"
      :approve_cancel -> "travel.order.cancelled"
      :complete_refund -> "travel.order.refund_completed"
      :mark_order_failed -> "travel.order.failed"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboExPoc.Travel.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
