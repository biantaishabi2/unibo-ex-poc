defmodule UniboV4.Fleet.Fleet.VehicleContract.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :terminate -> "fleet.contract.terminated"
      :renew -> "fleet.contract.renewed"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboV4.Fleet.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
