defmodule UniboV4.IoT.VoIPCall.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :answer -> "voip.call.answered"
      :end_call -> "voip.call.ended"
      :miss -> "voip.call.missed"
      :hold -> "voip.call.held"
      :unhold -> "voip.call.resumed"
      :transfer -> "voip.call.transferred"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboV4.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
