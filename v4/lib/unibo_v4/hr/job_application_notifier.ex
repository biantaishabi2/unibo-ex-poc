defmodule UniboV4.HR.JobApplication.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :hire -> "hr.application.hired"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
