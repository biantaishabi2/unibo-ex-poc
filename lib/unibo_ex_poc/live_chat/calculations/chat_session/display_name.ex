defmodule UniboExPoc.LiveChat.Calculations.ChatSession.DisplayName do
  @moduledoc """
  Calculation 模块: :display_name (type: :string, entity: chat_session)
  原始 expr: op: coalesce args: - op: ref   args:   - anonymous_name - op: ref   args:   - operator   - name
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :display_name 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
