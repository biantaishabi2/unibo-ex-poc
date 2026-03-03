defmodule UniboV4.Lunch.LunchOrder.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :action_order -> "lunch.order.ordered"
      :action_send -> "lunch.order.sent"
      :action_confirm -> "lunch.order.confirmed"
      :action_cancel -> "lunch.order.cancelled"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboV4.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
