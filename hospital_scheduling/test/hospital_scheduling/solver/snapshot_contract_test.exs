defmodule HospitalScheduling.Solver.SnapshotContractTest do
  use HospitalScheduling.DataCase, async: false

  alias HospitalScheduling.Solver.SnapshotAssembler
  alias HospitalScheduling.Scheduling

  # 辅助函数：跨域引用实体用 Repo 直接插入（UUID 需要转二进制）
  defp create_department! do
    id = Ash.UUID.generate()
    {:ok, bin_id} = Ecto.UUID.dump(id)
    {:ok, _} = Ecto.Adapters.SQL.query(HospitalScheduling.Repo,
      "INSERT INTO scheduling_departments (id, name) VALUES ($1, $2)", [bin_id, "ICU"])
    {:ok, dept} = Ash.get(Scheduling.Department, id, authorize?: false)
    dept
  end

  defp create_employee!(code, name) do
    id = Ash.UUID.generate()
    {:ok, bin_id} = Ecto.UUID.dump(id)
    {:ok, _} = Ecto.Adapters.SQL.query(HospitalScheduling.Repo,
      "INSERT INTO scheduling_employees (id, employee_code, name) VALUES ($1, $2, $3)", [bin_id, code, name])
    {:ok, emp} = Ash.get(Scheduling.Employee, id, authorize?: false)
    emp
  end

  defp create_shift_type!(dept) do
    {:ok, st} = Ash.create(Scheduling.ShiftType, %{
      department_id: dept.id,
      code: "day",
      name: "白班",
      start_time: "08:00:00",
      end_time: "16:00:00",
      duration_hours: Decimal.new("8"),
      is_night: false
    }, authorize?: false)
    st
  end

  defp create_period!(dept) do
    {:ok, period} = Ash.create(Scheduling.SchedulingPeriod, %{
      department_id: dept.id,
      start_date: ~D[2026-04-01],
      end_date: ~D[2026-04-30],
      title: "ICU 2026-04 月排班"
    }, authorize?: false)
    period
  end

  describe "input_snapshot 契约" do
    test "完整 snapshot 包含所有必需顶层字段" do
      dept = create_department!()
      emp = create_employee!("N001", "张三")
      shift_type = create_shift_type!(dept)
      period = create_period!(dept)

      # 创建 requirement
      {:ok, _req} = Ash.create(Scheduling.CoverageRequirement, %{
        period_id: period.id,
        shift_type_id: shift_type.id,
        requirement_date: ~D[2026-04-01],
        role_code: "duty_nurse",
        required_skill_tags: Jason.encode!(["ICU"]),
        min_headcount: 2,
        target_headcount: 3,
        required_lead_count: 1,
        priority: 100
      }, authorize?: false)

      # 创建 constraint
      {:ok, _constraint} = Ash.create(Scheduling.SchedulingConstraint, %{
        department_id: dept.id,
        name: "夜班后休息",
        constraint_type: :hard,
        category: :rest_after_night,
        params: Jason.encode!(%{"min_hours" => 12})
      }, authorize?: false)

      # 创建 profile
      {:ok, _profile} = Ash.create(Scheduling.MedicalStaffProfile, %{
        employee_id: emp.id,
        department_id: dept.id,
        maturity_score: Decimal.new("85"),
        can_lead_shift: true,
        work_restrictions: "[]",
        overtime_willing: false
      }, authorize?: false)

      # 创建 preference
      {:ok, _pref} = Ash.create(Scheduling.ShiftPreference, %{
        employee_id: emp.id,
        period_id: period.id,
        preferred_shift_tags: Jason.encode!(["day"]),
        unavailable_dates: Jason.encode!(["2026-04-05"]),
        max_night_shifts: 4
      }, authorize?: false)

      # 组装 snapshot
      assert {:ok, snapshot} = SnapshotAssembler.assemble(period.id, seed: 42, timeout_ms: 30_000)

      # 验证顶层结构
      assert Map.has_key?(snapshot, "period")
      assert Map.has_key?(snapshot, "requirements")
      assert Map.has_key?(snapshot, "constraints")
      assert Map.has_key?(snapshot, "shift_types")
      assert Map.has_key?(snapshot, "medical_staff_profiles")
      assert Map.has_key?(snapshot, "preferences")
      assert Map.has_key?(snapshot, "locked_assignments")
      assert Map.has_key?(snapshot, "run_options")

      # 验证 period 结构
      period_data = snapshot["period"]
      assert period_data["id"] != nil
      assert period_data["department_id"] != nil
      assert period_data["start_date"] == "2026-04-01"
      assert period_data["end_date"] == "2026-04-30"

      # 验证 requirements 结构
      [req | _] = snapshot["requirements"]
      assert req["id"] != nil
      assert req["date"] == "2026-04-01"
      assert req["shift_type_id"] != nil
      assert req["role_code"] == "duty_nurse"
      assert req["required_skill_tags"] == ["ICU"]
      assert req["min_headcount"] == 2
      assert req["target_headcount"] == 3
      assert req["required_lead_count"] == 1
      assert req["priority"] == 100

      # 验证 constraints 结构
      [constraint | _] = snapshot["constraints"]
      assert constraint["id"] != nil
      assert constraint["constraint_type"] == "hard"
      assert constraint["category"] == "rest_after_night"
      assert constraint["params"] == %{"min_hours" => 12}

      # 验证 shift_types 结构
      [st | _] = snapshot["shift_types"]
      assert st["id"] != nil
      assert st["code"] == "day"
      assert st["is_night"] == false
      assert st["duration_hours"] == 8.0

      # 验证 medical_staff_profiles 结构
      [profile | _] = snapshot["medical_staff_profiles"]
      assert profile["employee_id"] != nil
      assert profile["can_lead_shift"] == true
      assert profile["maturity_score"] == 85.0

      # 验证 preferences 结构
      [pref | _] = snapshot["preferences"]
      assert pref["employee_id"] != nil
      assert pref["preferred_shift_tags"] == ["day"]
      assert pref["unavailable_dates"] == ["2026-04-05"]
      assert pref["max_night_shifts"] == 4

      # 验证 run_options
      assert snapshot["run_options"]["seed"] == 42
      assert snapshot["run_options"]["timeout_ms"] == 30_000
      assert snapshot["run_options"]["engine_type"] == "cp_sat"
    end

    test "snapshot 可以序列化为 JSON 并反序列化" do
      dept = create_department!()
      _emp = create_employee!("N002", "李四")
      _shift_type = create_shift_type!(dept)
      period = create_period!(dept)

      {:ok, snapshot} = SnapshotAssembler.assemble(period.id)

      # 验证 JSON 往返
      json = Jason.encode!(snapshot)
      assert {:ok, decoded} = Jason.decode(json)
      assert decoded["period"]["start_date"] == "2026-04-01"
    end
  end
end
