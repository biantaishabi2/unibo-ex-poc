defmodule UniboExPoc.Documents.Document.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :upload -> "documents.document.uploaded"
      :update -> "documents.document.updated"
      :archive -> "documents.document.archived"
      :lock -> "documents.document.locked"
      :unlock -> "documents.document.unlocked"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboExPoc.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
