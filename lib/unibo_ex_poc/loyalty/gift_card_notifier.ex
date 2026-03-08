defmodule UniboV4.Loyalty.GiftCard.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :activate -> "loyalty.giftcard.activated"
      :charge -> "loyalty.giftcard.charged"
      :topup -> "loyalty.giftcard.topup"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboV4.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
