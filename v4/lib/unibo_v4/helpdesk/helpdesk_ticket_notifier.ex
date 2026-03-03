defmodule UniboV4.Helpdesk.HelpdeskTicket.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :create -> "helpdesk.ticket.created"
      :assign -> "helpdesk.ticket.assigned"
      :change_stage -> "helpdesk.ticket.stage_changed"
      :resolve -> "helpdesk.ticket.resolved"
      :close -> "helpdesk.ticket.closed"
      :reopen -> "helpdesk.ticket.reopened"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboV4.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
