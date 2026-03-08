defmodule UniboV4.Travel.TravelOrder.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :submit_order -> "travel.order.submitted"
      :submit_waitlist -> "travel.order.waitlist_submitted"
      :mark_payment_succeeded -> "travel.order.payment_confirmed"
      :fulfill_waitlist -> "travel.order.waitlist_fulfilled"
      :cancel_waitlist -> "travel.order.waitlist_cancelled"
      :approve_cancel -> "travel.order.cancelled"
      :confirm_change -> "travel.order.change_confirmed"
      :mark_order_failed -> "travel.order.failed"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboV4.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
