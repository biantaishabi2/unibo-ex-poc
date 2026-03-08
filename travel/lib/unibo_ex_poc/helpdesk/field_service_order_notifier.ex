defmodule UniboExPoc.Helpdesk.FieldServiceOrder.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :mark_done -> "helpdesk.field_service.completed"
      :start_timer -> "helpdesk.field_service.timer_started"
      :cancel -> "helpdesk.field_service.cancelled"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboExPoc.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
