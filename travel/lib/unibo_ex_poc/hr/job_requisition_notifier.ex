defmodule UniboExPoc.HR.JobRequisition.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :create -> "hr.requisition.created"
      :open -> "hr.requisition.opened"
      :close -> "hr.requisition.closed"
      :cancel -> "hr.requisition.cancelled"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboExPoc.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
