defmodule UniboV4.IoT.Calculations.IoTDevice.IsOnline do
  @moduledoc """
  Calculation 模块: :is_online (type: :boolean, entity: io_t_device)
  原始 expr: op: and args: - op: eq   args:   - op: ref     args:     - status   - connected - op: neq   args:   - op: ref     args:     - health_status   - error
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :is_online 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
