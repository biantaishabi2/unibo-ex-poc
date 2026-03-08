defmodule UniboV4.LiveChat.Calculations.LiveChatChannel.AreYouInside do
  @moduledoc """
  Calculation 模块: :are_you_inside (type: :boolean, entity: live_chat_channel)
  原始 expr: op: in args: - op: ref   args:   - actor   - id - op: ref   args:   - user_ids
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :are_you_inside 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
