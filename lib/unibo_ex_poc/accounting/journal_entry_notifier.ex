defmodule UniboExPoc.Accounting.JournalEntry.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :post -> "accounting.journal.posted"
      :cancel -> "accounting.journal.cancelled"
      :reset_to_draft -> "accounting.journal.reset_to_draft"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboExPoc.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
