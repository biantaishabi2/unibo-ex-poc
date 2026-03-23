defmodule HospitalScheduling.PubSub do
  @moduledoc """
  Ash PubSub 通知模块，将 Ash 资源事件广播到 Phoenix.PubSub。
  """

  def broadcast(topic, event, notification) do
    Phoenix.PubSub.broadcast(
      HospitalScheduling.InternalPubSub,
      topic,
      {event, notification}
    )
  end
end
