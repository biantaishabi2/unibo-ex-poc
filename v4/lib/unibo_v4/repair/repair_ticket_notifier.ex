defmodule UniboV4.Repair.Repair.RepairTicket.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :confirm -> "repair.ticket.confirmed"
      :start_repair -> "repair.ticket.started"
      :complete_repair -> "repair.ticket.repaired"
      :deliver -> "repair.ticket.delivered"
      :cancel -> "repair.ticket.cancelled"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboV4.Repair.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
