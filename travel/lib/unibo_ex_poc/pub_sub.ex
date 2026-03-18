defmodule UniboExPoc.PubSub do
  @moduledoc """
  PubSub 封装模块，供 Ash.Notifier.PubSub 使用。
  """

  def broadcast(topic, event, notification) do
    Phoenix.PubSub.broadcast(__MODULE__, topic, {event, notification})
  end
end
