defmodule UniboExPoc.Forum.Post.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :create -> "forum.post.created"
      :validate -> "forum.post.validated"
      :close -> "forum.post.closed"
      :flag -> "forum.post.flagged"
      :mark_offensive -> "forum.post.marked_offensive"
      :accept_answer -> "forum.post.answer_accepted"
      :unaccept_answer -> "forum.post.answer_unaccepted"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboExPoc.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
