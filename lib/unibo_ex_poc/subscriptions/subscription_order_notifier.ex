defmodule UniboV4.Subscriptions.SubscriptionOrder.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :action_confirm -> "subscriptions.order.confirmed"
      :action_pause -> "subscriptions.order.paused"
      :action_resume -> "subscriptions.order.resumed"
      :action_close -> "subscriptions.order.closed"
      :action_renew -> "subscriptions.order.renewed"
      :action_upsell -> "subscriptions.order.upsold"
      :mark_payment_exception -> "subscriptions.order.payment_failed"
      :clear_payment_exception -> "subscriptions.order.payment_recovered"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboV4.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
