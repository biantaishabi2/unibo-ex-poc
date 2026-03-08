defmodule UniboV4.Approvals.ApprovalRequest.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :submit -> "approvals.request.submitted"
      :approve -> "approvals.request.approved"
      :refuse -> "approvals.request.refused"
      :cancel -> "approvals.request.cancelled"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboV4.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
