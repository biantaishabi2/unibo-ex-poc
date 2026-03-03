defmodule UniboV4.Rating.Rating.Rating.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :submit -> "rating.submitted"
      :approve -> "rating.approved"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboV4.Rating.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
