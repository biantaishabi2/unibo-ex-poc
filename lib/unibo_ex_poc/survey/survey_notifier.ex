defmodule UniboExPoc.Survey.Survey.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :action_open -> "survey.survey.opened"
      :action_close -> "survey.survey.closed"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboExPoc.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
