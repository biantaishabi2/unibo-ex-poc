defmodule UniboV4.Events.Events.Event.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :publish -> "events.event.published"
      :cancel -> "events.event.cancelled"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboV4.Events.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
