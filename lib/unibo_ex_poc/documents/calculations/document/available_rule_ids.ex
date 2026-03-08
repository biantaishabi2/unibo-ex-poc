defmodule UniboV4.Documents.Calculations.Document.AvailableRuleIds do
  @moduledoc """
  Calculation 模块: :available_rule_ids (type: {:array, :string}, entity: document)
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :available_rule_ids 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
