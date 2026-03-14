defmodule HospitalScheduling.Solver.SnapshotAssembler do
  @moduledoc """
  从数据库组装 SolverRun.input_snapshot JSON。

  读取 SchedulingPeriod 下的 requirements、constraints、employees、
  medical_staff_profiles、shift_preferences，组装成冻结的求解输入快照。
  """

  alias HospitalScheduling.Scheduling

  require Ash.Query

  @doc """
  为指定的 SchedulingPeriod 组装 input_snapshot。

  返回 `{:ok, snapshot_map}` 或 `{:error, reason}`。
  """
  def assemble(period_id, opts \\ []) do
    with {:ok, period} <- load_period(period_id),
         {:ok, requirements} <- load_requirements(period_id),
         {:ok, constraints} <- load_constraints(period.department_id),
         {:ok, shift_types} <- load_shift_types(period.department_id),
         {:ok, profiles} <- load_medical_staff_profiles(period.department_id),
         {:ok, preferences} <- load_shift_preferences(period_id) do
      snapshot = build_snapshot(period, requirements, constraints, shift_types, profiles, preferences, opts)
      {:ok, snapshot}
    end
  end

  defp load_period(period_id) do
    Scheduling.SchedulingPeriod
    |> Ash.Query.filter(id == ^period_id)
    |> Ash.read_one(authorize?: false)
    |> case do
      {:ok, nil} -> {:error, "SchedulingPeriod #{period_id} not found"}
      {:ok, period} -> {:ok, period}
      error -> error
    end
  end

  defp load_requirements(period_id) do
    Scheduling.CoverageRequirement
    |> Ash.Query.filter(period_id == ^period_id)
    |> Ash.Query.load([:shift_type])
    |> Ash.read(authorize?: false)
  end

  defp load_constraints(department_id) do
    Scheduling.SchedulingConstraint
    |> Ash.Query.filter(department_id == ^department_id and enabled == true)
    |> Ash.read(authorize?: false)
  end

  defp load_shift_types(department_id) do
    Scheduling.ShiftType
    |> Ash.Query.filter(department_id == ^department_id and enabled == true)
    |> Ash.read(authorize?: false)
  end

  defp load_medical_staff_profiles(department_id) do
    Scheduling.MedicalStaffProfile
    |> Ash.Query.filter(department_id == ^department_id)
    |> Ash.read(authorize?: false)
  end

  defp load_shift_preferences(period_id) do
    Scheduling.ShiftPreference
    |> Ash.Query.filter(period_id == ^period_id)
    |> Ash.read(authorize?: false)
    |> case do
      {:ok, prefs} -> {:ok, prefs}
      # 没有偏好也正常
      _ -> {:ok, []}
    end
  end

  defp build_snapshot(period, requirements, constraints, shift_types, profiles, preferences, opts) do
    locked_assignments = Keyword.get(opts, :locked_assignments, [])
    seed = Keyword.get(opts, :seed, nil)
    timeout_ms = Keyword.get(opts, :timeout_ms, 30_000)
    engine_type = Keyword.get(opts, :engine_type, "cp_sat")

    %{
      "period" => serialize_period(period),
      "requirements" => Enum.map(requirements, &serialize_requirement/1),
      "constraints" => Enum.map(constraints, &serialize_constraint/1),
      "shift_types" => Enum.map(shift_types, &serialize_shift_type/1),
      "medical_staff_profiles" => Enum.map(profiles, &serialize_profile/1),
      "preferences" => Enum.map(preferences, &serialize_preference/1),
      "locked_assignments" => Enum.map(locked_assignments, &serialize_locked_assignment/1),
      "run_options" => %{
        "seed" => seed,
        "timeout_ms" => timeout_ms,
        "engine_type" => engine_type
      }
    }
  end

  defp serialize_period(p) do
    %{
      "id" => to_string(p.id),
      "department_id" => to_string(p.department_id),
      "start_date" => Date.to_iso8601(p.start_date),
      "end_date" => Date.to_iso8601(p.end_date),
      "state" => to_string(p.state)
    }
  end

  defp serialize_requirement(r) do
    %{
      "id" => to_string(r.id),
      "date" => Date.to_iso8601(r.requirement_date),
      "shift_type_id" => to_string(r.shift_type_id),
      "role_code" => r.role_code,
      "required_skill_tags" => parse_json_array(r.required_skill_tags),
      "min_headcount" => r.min_headcount,
      "target_headcount" => r.target_headcount || r.min_headcount,
      "required_lead_count" => r.required_lead_count,
      "priority" => r.priority
    }
  end

  defp serialize_constraint(c) do
    %{
      "id" => to_string(c.id),
      "constraint_type" => to_string(c.constraint_type),
      "category" => to_string(c.category),
      "params" => parse_json_map(c.params),
      "weight" => c.weight || 0
    }
  end

  defp serialize_shift_type(st) do
    %{
      "id" => to_string(st.id),
      "code" => st.code,
      "name" => st.name,
      "start_time" => st.start_time,
      "end_time" => st.end_time,
      "duration_hours" => decimal_to_float(st.duration_hours),
      "is_night" => st.is_night
    }
  end

  defp serialize_profile(p) do
    %{
      "employee_id" => to_string(p.employee_id),
      "department_id" => to_string(p.department_id),
      "maturity_score" => decimal_to_float(p.maturity_score),
      "can_lead_shift" => p.can_lead_shift,
      "work_restrictions" => parse_json_array(p.work_restrictions),
      "overtime_willing" => p.overtime_willing
    }
  end

  defp serialize_preference(p) do
    %{
      "employee_id" => to_string(p.employee_id),
      "preferred_shift_tags" => parse_json_array(p.preferred_shift_tags),
      "unavailable_dates" => parse_json_array(p.unavailable_dates),
      "max_night_shifts" => p.max_night_shifts
    }
  end

  defp parse_json_array(nil), do: []
  defp parse_json_array(list) when is_list(list), do: list
  defp parse_json_array(str) when is_binary(str) do
    case Jason.decode(str) do
      {:ok, list} when is_list(list) -> list
      _ -> []
    end
  end

  defp parse_json_map(nil), do: %{}
  defp parse_json_map(map) when is_map(map), do: map
  defp parse_json_map(str) when is_binary(str) do
    case Jason.decode(str) do
      {:ok, map} when is_map(map) -> map
      _ -> %{}
    end
  end

  defp decimal_to_float(%Decimal{} = d), do: Decimal.to_float(d)
  defp decimal_to_float(n) when is_number(n), do: n / 1
  defp decimal_to_float(s) when is_binary(s), do: String.to_float(s)
  defp decimal_to_float(nil), do: 0.0

  defp serialize_locked_assignment(a) do
    %{
      "employee_id" => to_string(a.employee_id),
      "requirement_id" => to_string(a.requirement_id),
      "starts_at" => DateTime.to_iso8601(a.starts_at),
      "ends_at" => DateTime.to_iso8601(a.ends_at)
    }
  end
end
