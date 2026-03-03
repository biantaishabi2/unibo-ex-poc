defmodule UniboV4.Rental.RentalOrder.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :action_confirm -> "rental.order.confirmed"
      :action_pickup -> "rental.order.picked_up"
      :action_return -> "rental.order.returned"
      :action_done -> "rental.order.done"
      :action_cancel -> "rental.order.cancelled"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboV4.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
