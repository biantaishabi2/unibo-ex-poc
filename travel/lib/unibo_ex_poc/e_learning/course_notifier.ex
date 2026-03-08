defmodule UniboExPoc.ELearning.Course.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :publish -> "elearning.course.published"
      :unpublish -> "elearning.course.unpublished"
      :archive -> "elearning.course.archived"
      :restore -> "elearning.course.restored"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboExPoc.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
