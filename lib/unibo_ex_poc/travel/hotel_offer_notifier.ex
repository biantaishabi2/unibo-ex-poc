defmodule UniboExPoc.Travel.HotelOffer.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :activate -> "travel.catalog.hotel_offer.activated"
      :deactivate -> "travel.catalog.hotel_offer.deactivated"
      :expire -> "travel.catalog.hotel_offer.expired"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboExPoc.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
