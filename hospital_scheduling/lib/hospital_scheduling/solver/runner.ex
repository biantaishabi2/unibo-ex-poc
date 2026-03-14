defmodule HospitalScheduling.Solver.Runner do
  @moduledoc """
  Solver 运行编排器。

  负责完整的求解生命周期：
  1. 组装 input_snapshot
  2. 创建 SolverRun 记录
  3. 调用 solver（当前先用 mock，后续接 Rust Port/NIF）
  4. 将结果写回数据库
  """

  alias HospitalScheduling.Solver.{SnapshotAssembler, ResultWriter, AggregateChecker}
  alias HospitalScheduling.Scheduling

  require Logger

  @doc """
  对指定的 SchedulingPeriod 执行一次完整求解。

  选项：
  - `:seed` - 随机种子（可复现）
  - `:timeout_ms` - 超时毫秒数（默认 30000）
  - `:engine_type` - 算法标识（默认 "cp_sat"）
  - `:locked_assignments` - 锁定的排班列表
  - `:solver_adapter` - solver 适配器模块（默认 MockSolverAdapter，测试用）

  返回 `{:ok, result}` 或 `{:error, reason}`。
  """
  def run(period_id, opts \\ []) do
    solver_adapter = Keyword.get(opts, :solver_adapter, HospitalScheduling.Solver.MockAdapter)

    with {:ok, snapshot} <- SnapshotAssembler.assemble(period_id, opts),
         {:ok, period} <- load_period(period_id),
         {:ok, solver_run} <- create_solver_run(period, snapshot, opts),
         {:ok, running_run} <- mark_running(solver_run),
         {:ok, output} <- invoke_solver(solver_adapter, snapshot, opts),
         {:ok, result} <- ResultWriter.write_result(running_run, output, period) do
      # 更新 period 状态
      update_period_after_solve(period)
      {:ok, result}
    else
      {:error, reason} = error ->
        Logger.error("Solver run failed: #{inspect(reason)}")
        error
    end
  end

  @doc """
  对指定的 ScheduleVersion 执行发布前 aggregate check。

  返回 `{:ok, %{errors: [...], warnings: [...]}}` 或 `{:error, reason}`。
  """
  def pre_publish_check(version_id) do
    AggregateChecker.check(version_id)
  end

  defp load_period(period_id) do
    require Ash.Query

    Scheduling.SchedulingPeriod
    |> Ash.Query.filter(id == ^period_id)
    |> Ash.read_one(authorize?: false)
    |> case do
      {:ok, nil} -> {:error, "Period not found"}
      {:ok, period} -> {:ok, period}
      error -> error
    end
  end

  defp create_solver_run(period, snapshot, opts) do
    seed = Keyword.get(opts, :seed)
    timeout_ms = Keyword.get(opts, :timeout_ms, 30_000)
    engine_type = Keyword.get(opts, :engine_type, "cp_sat")

    Ash.create(Scheduling.SolverRun, %{
      period_id: period.id,
      engine_type: engine_type,
      seed: seed,
      timeout_ms: timeout_ms,
      input_snapshot: Jason.encode!(snapshot)
    }, authorize?: false)
  end

  defp mark_running(solver_run) do
    Ash.update(solver_run, %{}, action: :start_run, authorize?: false)
  end

  defp invoke_solver(adapter, snapshot, opts) do
    timeout_ms = Keyword.get(opts, :timeout_ms, 30_000)

    task = Task.async(fn ->
      adapter.solve(snapshot, opts)
    end)

    case Task.yield(task, timeout_ms) || Task.shutdown(task, :brutal_kill) do
      {:ok, result} -> result
      nil -> {:error, :timeout}
    end
  end

  defp update_period_after_solve(period) do
    if period.state == :generating do
      Ash.update(period, %{}, action: :mark_generated, authorize?: false)
    end
  end
end
