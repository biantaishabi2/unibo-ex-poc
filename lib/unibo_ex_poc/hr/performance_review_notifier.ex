defmodule UniboV4.HR.PerformanceReview.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :create -> "hr.appraisal.created"
      :action_confirm -> "hr.appraisal.confirmed"
      :action_done -> "hr.appraisal.done"
      :action_cancel -> "hr.appraisal.cancelled"
      :action_back -> "hr.appraisal.reopened"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboV4.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
