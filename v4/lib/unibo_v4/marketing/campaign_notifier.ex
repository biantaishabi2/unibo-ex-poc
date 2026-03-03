defmodule UniboV4.Marketing.Campaign.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :launch -> "marketing.campaign.launched"
      :pause -> "marketing.campaign.paused"
      :resume -> "marketing.campaign.resumed"
      :complete -> "marketing.campaign.completed"
      :cancel -> "marketing.campaign.cancelled"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboV4.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
