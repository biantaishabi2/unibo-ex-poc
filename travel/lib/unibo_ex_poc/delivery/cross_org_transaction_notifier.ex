defmodule UniboExPoc.Delivery.CrossOrgTransaction.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :confirm_source -> "delivery.cross_org_transaction.source_confirmed"
      :create_mirror_purchase_order -> "delivery.cross_org_transaction.mirror_created"
      :mark_fulfilled -> "delivery.cross_org_transaction.fulfilled"
      :mark_settled -> "delivery.cross_org_transaction.settled"
      :mark_failed -> "delivery.cross_org_transaction.failed"
      :cancel -> "delivery.cross_org_transaction.cancelled"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboExPoc.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
