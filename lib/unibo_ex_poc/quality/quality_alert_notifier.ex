defmodule UniboExPoc.Quality.QualityAlert.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :confirm -> "quality.alert.confirmed"
      :start_progress -> "quality.alert.in_progress"
      :done -> "quality.alert.done"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboExPoc.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
