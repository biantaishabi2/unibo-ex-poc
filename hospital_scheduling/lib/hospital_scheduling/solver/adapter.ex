defmodule HospitalScheduling.Solver.Adapter do
  @moduledoc """
  Solver adapter behaviour。

  所有求解后端（mock、Rust CP-SAT 等）必须实现此接口。
  """

  @doc """
  执行求解。

  输入：input_snapshot map + 选项
  输出：`{:ok, output_snapshot_map}` 或 `{:error, reason}`
  """
  @callback solve(snapshot :: map(), opts :: keyword()) ::
              {:ok, map()} | {:error, term()}
end
