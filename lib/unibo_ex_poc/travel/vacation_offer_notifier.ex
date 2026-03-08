defmodule UniboV4.Travel.VacationOffer.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :activate -> "travel.catalog.vacation_offer.activated"
      :deactivate -> "travel.catalog.vacation_offer.deactivated"
      :expire -> "travel.catalog.vacation_offer.expired"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboV4.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
