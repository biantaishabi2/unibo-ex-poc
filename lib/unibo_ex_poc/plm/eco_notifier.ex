defmodule UniboExPoc.PLM.Eco.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :create -> "plm.eco.created"
      :advance_stage -> "plm.eco.stage_advanced"
      :apply_changes -> "plm.eco.changes_applied"
      :rebase -> "plm.eco.rebased"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboExPoc.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
