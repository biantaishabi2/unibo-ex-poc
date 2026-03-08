defmodule UniboV4.Sign.SignRequest.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :send -> "sign.request.sent"
      :complete -> "sign.request.completed"
      :cancel -> "sign.request.canceled"
      :expire -> "sign.request.expired"
      :recall -> "sign.request.recalled"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboV4.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
