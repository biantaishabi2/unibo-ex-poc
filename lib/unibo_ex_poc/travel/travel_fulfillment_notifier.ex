defmodule UniboExPoc.Travel.TravelFulfillment.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :confirm_booking -> "travel.fulfillment.confirmed"
      :issue_voucher_or_ticket -> "travel.fulfillment.issued"
      :complete_fulfillment -> "travel.fulfillment.completed"
      :cancel_fulfillment -> "travel.fulfillment.cancelled"
      :fail_fulfillment -> "travel.fulfillment.failed"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboExPoc.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
