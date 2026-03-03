defmodule UniboV4.Analytic.Analytic.AnalyticDistribution.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :create -> "analytic.distribution.applied"
      :update -> "analytic.distribution.changed"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboV4.Analytic.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
