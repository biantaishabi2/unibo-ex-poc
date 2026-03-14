defmodule HospitalScheduling.Solver.ResultWriter do
  @moduledoc """
  将 solver output_snapshot 写回数据库。

  创建 ScheduleVersion + ShiftAssignment + ConstraintViolation，
  并更新 SolverRun 状态。
  """

  alias HospitalScheduling.Scheduling

  @doc """
  将求解结果落库。

  参数：
  - solver_run: 当前 SolverRun 记录
  - output: solver 输出的 map（解析后的 output_snapshot）
  - period: SchedulingPeriod 记录

  返回 `{:ok, %{version: version, assignments: [assignment], violations: [violation]}}` 或 `{:error, reason}`。
  """
  def write_result(solver_run, output, period) do
    summary = Map.get(output, "summary", %{})
    assignments_data = Map.get(output, "assignments", [])
    violations_data = Map.get(output, "violations", [])
    status = determine_status(summary)

    HospitalScheduling.Repo.transaction(fn ->
      # 1. 创建 ScheduleVersion
      {:ok, version} = create_version(period, solver_run, status)

      # 2. 创建 ShiftAssignment 记录
      assignments =
        Enum.map(assignments_data, fn a ->
          {:ok, assignment} = create_assignment(a, period, version)
          assignment
        end)

      # 3. 创建 ConstraintViolation 记录
      violations =
        Enum.map(violations_data, fn v ->
          {:ok, violation} = create_violation(v, period, version)
          violation
        end)

      # 4. 更新 SolverRun 状态和 output_snapshot
      {:ok, _updated_run} = update_solver_run(solver_run, status, output)

      %{version: version, assignments: assignments, violations: violations}
    end)
  end

  defp determine_status(summary) do
    error_count = Map.get(summary, "error_count", 0)
    assignment_count = Map.get(summary, "assignment_count", 0)

    cond do
      assignment_count == 0 -> :infeasible
      error_count > 0 -> :feasible
      true -> :feasible
    end
  end

  defp create_version(period, solver_run, _status) do
    # 计算下一个版本号
    next_version_no = get_next_version_no(period.id)

    Ash.create(Scheduling.ScheduleVersion, %{
      period_id: period.id,
      version_no: next_version_no,
      origin_type: :solver,
      based_on_run_id: solver_run.id,
      change_summary: "Solver generated version"
    }, authorize?: false)
  end

  defp get_next_version_no(period_id) do
    require Ash.Query

    case Scheduling.ScheduleVersion
         |> Ash.Query.filter(period_id == ^period_id)
         |> Ash.Query.sort(version_no: :desc)
         |> Ash.Query.limit(1)
         |> Ash.read(authorize?: false) do
      {:ok, [latest]} -> latest.version_no + 1
      _ -> 1
    end
  end

  defp create_assignment(data, period, version) do
    Ash.create(Scheduling.ShiftAssignment, %{
      period_id: period.id,
      version_id: version.id,
      requirement_id: data["requirement_id"],
      employee_id: data["employee_id"],
      starts_at: parse_datetime(data["starts_at"]),
      ends_at: parse_datetime(data["ends_at"]),
      source: String.to_existing_atom(data["source"] || "auto"),
      is_locked: data["is_locked"] || false,
      notes: data["notes"]
    }, authorize?: false)
  end

  defp create_violation(data, period, version) do
    details = data["details"] || %{}
    details_str = if is_binary(details), do: details, else: Jason.encode!(details)

    Ash.create(Scheduling.ConstraintViolation, %{
      period_id: period.id,
      version_id: version.id,
      assignment_id: data["assignment_id"],
      requirement_id: data["requirement_id"],
      rule_code: data["rule_code"],
      severity: String.to_existing_atom(data["severity"] || "warning"),
      message: data["message"],
      details_json: details_str
    }, authorize?: false)
  end

  defp update_solver_run(solver_run, status, output) do
    summary = Map.get(output, "summary", %{})
    action = status_to_action(status)

    attrs = %{
      score: summary["score"],
      hard_violation_count: summary["error_count"] || 0,
      warning_count: summary["warning_count"] || 0,
      output_snapshot: Jason.encode!(output)
    }

    Ash.update(solver_run, attrs, action: action, authorize?: false)
  end

  defp status_to_action(:feasible), do: :complete_feasible
  defp status_to_action(:infeasible), do: :complete_infeasible
  defp status_to_action(_), do: :complete_feasible

  defp parse_datetime(nil), do: nil
  defp parse_datetime(str) when is_binary(str) do
    case DateTime.from_iso8601(str) do
      {:ok, dt, _} -> dt
      _ -> nil
    end
  end
end
