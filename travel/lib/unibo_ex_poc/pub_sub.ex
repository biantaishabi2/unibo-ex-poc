defmodule UniboExPoc.PubSub do
  @doc """
  PubSub 模块，由 Phoenix.PubSub 在 Application 中启动。
  提供 Ash.Notifier.PubSub 要求的 broadcast/3 回调。
  """

  def broadcast(topic, event, notification) do
    Phoenix.PubSub.broadcast(
      UniboExPoc.PubSub,
      topic,
      {event, notification}
    )
  end
end
