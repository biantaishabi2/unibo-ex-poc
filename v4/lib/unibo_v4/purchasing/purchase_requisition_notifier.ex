defmodule UniboV4.Purchasing.PurchaseRequisition.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :action_in_progress -> "purchasing.requisition.confirmed"
      :action_done -> "purchasing.requisition.done"
      :action_cancel -> "purchasing.requisition.cancelled"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboV4.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
