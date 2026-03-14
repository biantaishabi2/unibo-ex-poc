defmodule HospitalScheduling.Solver.MockAdapter do
  @moduledoc """
  Mock solver adapter，用于测试。

  实现最简单的贪心分配：按 requirement priority 顺序，
  将可用 employee 分配到 assignment。
  """

  @behaviour HospitalScheduling.Solver.Adapter

  @impl true
  def solve(snapshot, _opts) do
    requirements = Map.get(snapshot, "requirements", [])
    profiles = Map.get(snapshot, "medical_staff_profiles", [])
    shift_types = Map.get(snapshot, "shift_types", [])
    period = Map.get(snapshot, "period", %{})

    # 按优先级排序
    sorted_reqs = Enum.sort_by(requirements, & &1["priority"])

    # 可用 employee 列表
    available_employees = Enum.map(profiles, & &1["employee_id"])

    # shift_type lookup
    shift_type_map = Map.new(shift_types, fn st -> {st["id"], st} end)

    # 贪心分配
    {assignments, violations, _used} =
      Enum.reduce(sorted_reqs, {[], [], MapSet.new()}, fn req, {assigns, viols, used_today} ->
        shift_type = Map.get(shift_type_map, req["shift_type_id"], %{})
        needed = req["min_headcount"] || 1
        date = req["date"]

        # 过滤当天已使用的 employee
        day_key = fn eid -> "#{eid}:#{date}" end
        free = Enum.filter(available_employees, fn eid -> not MapSet.member?(used_today, day_key.(eid)) end)

        # 取前 N 个
        chosen = Enum.take(free, needed)
        missing = needed - length(chosen)

        # 生成 assignments
        new_assigns =
          Enum.map(chosen, fn eid ->
            {starts_at, ends_at} = build_times(date, shift_type)
            %{
              "employee_id" => eid,
              "requirement_id" => req["id"],
              "starts_at" => starts_at,
              "ends_at" => ends_at,
              "source" => "auto",
              "is_locked" => false
            }
          end)

        # 生成 violations（人数不足）
        new_viols =
          if missing > 0 do
            [%{
              "rule_code" => "min_headcount",
              "severity" => "error",
              "requirement_id" => req["id"],
              "message" => "需要 #{needed} 人，只分配了 #{length(chosen)} 人",
              "details" => %{
                "source_level" => "requirement",
                "expected" => needed,
                "actual" => length(chosen)
              }
            }]
          else
            []
          end

        # lead 检查
        lead_viols =
          if (req["required_lead_count"] || 0) > 0 do
            lead_employees = Enum.filter(chosen, fn eid ->
              Enum.any?(profiles, fn p -> p["employee_id"] == eid and p["can_lead_shift"] end)
            end)

            if length(lead_employees) < req["required_lead_count"] do
              [%{
                "rule_code" => "lead_coverage",
                "severity" => "error",
                "requirement_id" => req["id"],
                "message" => "需要 #{req["required_lead_count"]} 名带班护士，实际 #{length(lead_employees)} 名",
                "details" => %{
                  "source_level" => "requirement",
                  "expected" => req["required_lead_count"],
                  "actual" => length(lead_employees)
                }
              }]
            else
              []
            end
          else
            []
          end

        new_used = Enum.reduce(chosen, used_today, fn eid, acc -> MapSet.put(acc, day_key.(eid)) end)
        {assigns ++ new_assigns, viols ++ new_viols ++ lead_viols, new_used}
      end)

    error_count = Enum.count(violations, fn v -> v["severity"] == "error" end)
    warning_count = Enum.count(violations, fn v -> v["severity"] == "warning" end)

    output = %{
      "summary" => %{
        "requirement_count" => length(requirements),
        "covered_requirement_count" => length(requirements) - error_count,
        "assignment_count" => length(assignments),
        "error_count" => error_count,
        "warning_count" => warning_count,
        "score" => 0,
        "seed" => get_in(snapshot, ["run_options", "seed"]),
        "engine_type" => "mock",
        "phase" => "completed"
      },
      "assignments" => assignments,
      "violations" => violations,
      "coverage" => build_coverage(sorted_reqs, assignments)
    }

    {:ok, output}
  end

  defp build_times(date, shift_type) do
    start_time = shift_type["start_time"] || "08:00:00"
    end_time = shift_type["end_time"] || "16:00:00"
    {"#{date}T#{start_time}Z", "#{date}T#{end_time}Z"}
  end

  defp build_coverage(requirements, assignments) do
    Enum.map(requirements, fn req ->
      assigned = Enum.count(assignments, fn a -> a["requirement_id"] == req["id"] end)
      %{
        "requirement_id" => req["id"],
        "required" => req["min_headcount"],
        "assigned" => assigned,
        "missing" => max(req["min_headcount"] - assigned, 0)
      }
    end)
  end
end
