defmodule UniboV4.Spreadsheet.Calculations.DataSource.LastRefreshedAt do
  @moduledoc """
  Calculation 模块: :last_refreshed_at (type: :utc_datetime, entity: data_source)
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :last_refreshed_at 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
