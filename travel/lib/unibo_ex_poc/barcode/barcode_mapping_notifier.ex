defmodule UniboExPoc.Barcode.BarcodeMapping.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :read -> "barcode.scanned"
      :register -> "barcode.mapping.registered"
      :deactivate -> "barcode.mapping.deactivated"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboExPoc.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
