defmodule UniboExPoc.LiveChat.Calculations.LiveChatChannel.AvailableOperatorIds do
  @moduledoc """
  Calculation 模块: :available_operator_ids (type: {:array, :string}, entity: live_chat_channel)
  原始 expr: op: custom args: []
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :available_operator_ids 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
