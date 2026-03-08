defmodule UniboExPoc.Knowledge.Article.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :action_publish -> "knowledge.article.published"
      :action_archive -> "knowledge.article.archived"
      :action_trash -> "knowledge.article.trashed"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboExPoc.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
