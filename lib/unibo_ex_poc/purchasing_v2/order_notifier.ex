defmodule UniboExPoc.PurchasingV2.OrderNotifier do
  @moduledoc """
  V2 订单通知器：将关键动作广播到 PubSub topic。
  """
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic =
      case action_name do
        :submit -> "purchasing.order.submitted"
        :approve -> "purchasing.order.approved"
        :reject -> "purchasing.order.rejected"
        _ -> nil
      end

    if topic do
      Phoenix.PubSub.broadcast(UniboExPoc.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
