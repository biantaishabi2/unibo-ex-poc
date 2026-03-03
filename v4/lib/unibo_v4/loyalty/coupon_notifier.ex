defmodule UniboV4.Loyalty.Loyalty.Coupon.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :apply -> "loyalty.coupon.used"
      :cancel_coupon -> "loyalty.coupon.cancelled"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboV4.Loyalty.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
