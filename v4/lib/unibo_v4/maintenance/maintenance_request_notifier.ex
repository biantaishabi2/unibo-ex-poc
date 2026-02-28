defmodule UniboV4.Maintenance.MaintenanceRequest.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :complete -> "maintenance.request.completed"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
