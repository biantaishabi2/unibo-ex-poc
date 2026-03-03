defmodule UniboV4.Payment.Payment.PaymentRefund.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :approve -> "payment.refund.approved"
      :process -> "payment.refund.processed"
      :reject -> "payment.refund.rejected"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboV4.Payment.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
