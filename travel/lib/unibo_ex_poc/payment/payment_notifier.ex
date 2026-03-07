defmodule UniboExPoc.Payment.Payment.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :authorize -> "payment.payment.authorized"
      :capture -> "payment.payment.captured"
      :refund -> "payment.payment.refunded"
      :cancel -> "payment.payment.cancelled"
      :mark_failed -> "payment.payment.failed"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboExPoc.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
