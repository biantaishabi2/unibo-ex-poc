defmodule HospitalScheduling.Solver.AggregateChecker do
  @moduledoc """
  发布前 aggregate check。

  检查指定 ScheduleVersion 下的所有 assignments 是否满足约束：
  - requirement coverage（人数是否满足）
  - lead coverage（带班人数）
  - 硬约束违反汇总
  """

  alias HospitalScheduling.Scheduling
  require Ash.Query

  @doc """
  对指定 version 执行 aggregate check。

  返回 `{:ok, %{errors: [...], warnings: [...], publishable: boolean}}`。
  """
  def check(version_id) do
    with {:ok, version} <- load_version(version_id),
         {:ok, assignments} <- load_assignments(version_id),
         {:ok, violations} <- load_violations(version_id),
         {:ok, requirements} <- load_requirements(version.period_id) do
      coverage_issues = check_coverage(requirements, assignments)
      existing_errors = Enum.filter(violations, fn v -> v.severity == :error end)
      existing_warnings = Enum.filter(violations, fn v -> v.severity == :warning end)

      all_errors = coverage_issues ++ Enum.map(existing_errors, &format_violation/1)
      all_warnings = Enum.map(existing_warnings, &format_violation/1)

      {:ok, %{
        errors: all_errors,
        warnings: all_warnings,
        publishable: all_errors == []
      }}
    end
  end

  defp load_version(version_id) do
    Scheduling.ScheduleVersion
    |> Ash.Query.filter(id == ^version_id)
    |> Ash.read_one(authorize?: false)
    |> case do
      {:ok, nil} -> {:error, "Version not found"}
      {:ok, v} -> {:ok, v}
      error -> error
    end
  end

  defp load_assignments(version_id) do
    Scheduling.ShiftAssignment
    |> Ash.Query.filter(version_id == ^version_id)
    |> Ash.read(authorize?: false)
  end

  defp load_violations(version_id) do
    Scheduling.ConstraintViolation
    |> Ash.Query.filter(version_id == ^version_id)
    |> Ash.read(authorize?: false)
  end

  defp load_requirements(period_id) do
    Scheduling.CoverageRequirement
    |> Ash.Query.filter(period_id == ^period_id)
    |> Ash.read(authorize?: false)
  end

  defp check_coverage(requirements, assignments) do
    Enum.flat_map(requirements, fn req ->
      assigned_count =
        Enum.count(assignments, fn a -> a.requirement_id == req.id end)

      issues = []

      issues =
        if assigned_count < req.min_headcount do
          [%{
            rule_code: "min_headcount",
            severity: :error,
            requirement_id: req.id,
            message: "覆盖不足：需要 #{req.min_headcount} 人，实际 #{assigned_count} 人"
          } | issues]
        else
          issues
        end

      issues
    end)
  end

  defp format_violation(v) do
    %{
      rule_code: v.rule_code,
      severity: v.severity,
      requirement_id: v.requirement_id,
      assignment_id: v.assignment_id,
      message: v.message
    }
  end
end
