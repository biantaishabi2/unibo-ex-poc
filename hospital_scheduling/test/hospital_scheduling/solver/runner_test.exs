defmodule HospitalScheduling.Solver.RunnerTest do
  use HospitalScheduling.DataCase, async: false

  alias HospitalScheduling.Solver.Runner
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

  defp create_shift_type!(dept, code, name, start_time, end_time, hours, is_night \\ false) do
    {:ok, st} = Ash.create(Scheduling.ShiftType, %{
      department_id: dept.id,
      code: code,
      name: name,
      start_time: start_time,
      end_time: end_time,
      duration_hours: Decimal.new(hours),
      is_night: is_night
    }, authorize?: false)
    st
  end

  defp create_period!(dept, start_date, end_date) do
    {:ok, period} = Ash.create(Scheduling.SchedulingPeriod, %{
      department_id: dept.id,
      start_date: start_date,
      end_date: end_date,
      title: "Test Period"
    }, authorize?: false)
    period
  end

  defp create_requirement!(period, shift_type, date, min_headcount, opts \\ []) do
    {:ok, req} = Ash.create(Scheduling.CoverageRequirement, %{
      period_id: period.id,
      shift_type_id: shift_type.id,
      requirement_date: date,
      role_code: Keyword.get(opts, :role_code, "nurse"),
      min_headcount: min_headcount,
      required_lead_count: Keyword.get(opts, :required_lead_count, 0),
      priority: Keyword.get(opts, :priority, 100)
    }, authorize?: false)
    req
  end

  defp create_profile!(emp, dept, opts \\ []) do
    {:ok, profile} = Ash.create(Scheduling.MedicalStaffProfile, %{
      employee_id: emp.id,
      department_id: dept.id,
      maturity_score: Keyword.get(opts, :maturity_score, Decimal.new("50")),
      can_lead_shift: Keyword.get(opts, :can_lead_shift, false),
      overtime_willing: false
    }, authorize?: false)
    profile
  end

  describe "run/2" do
    test "完整求解链路：snapshot -> solver -> version/assignment/violation 落库" do
      # 准备数据
      dept = create_department!()
      emp1 = create_employee!("N001", "张三")
      emp2 = create_employee!("N002", "李四")

      day_shift = create_shift_type!(dept, "day", "白班", "08:00:00", "16:00:00", "8")

      period = create_period!(dept, ~D[2026-04-01], ~D[2026-04-30])

      _req1 = create_requirement!(period, day_shift, ~D[2026-04-01], 2)

      _p1 = create_profile!(emp1, dept)
      _p2 = create_profile!(emp2, dept)

      # 执行求解
      assert {:ok, result} = Runner.run(period.id, seed: 42, timeout_ms: 10_000)

      # 验证结果
      assert %{version: version, assignments: assignments, violations: _violations} = result
      assert version.version_no == 1
      assert version.origin_type == :solver
      assert length(assignments) == 2
    end

    test "人数不足时产生 error violation" do
      dept = create_department!()
      emp1 = create_employee!("N003", "王五")

      day_shift = create_shift_type!(dept, "day", "白班", "08:00:00", "16:00:00", "8")
      period = create_period!(dept, ~D[2026-04-01], ~D[2026-04-30])

      # 需要 3 人但只有 1 人可用
      _req = create_requirement!(period, day_shift, ~D[2026-04-01], 3)
      _p1 = create_profile!(emp1, dept)

      assert {:ok, result} = Runner.run(period.id)

      # 应该有 violation
      assert length(result.violations) > 0
      error_viols = Enum.filter(result.violations, fn v -> v.severity == :error end)
      assert length(error_viols) > 0
    end
  end

  describe "pre_publish_check/1" do
    test "无 error 时允许发布" do
      dept = create_department!()
      emp1 = create_employee!("N004", "赵六")

      day_shift = create_shift_type!(dept, "day", "白班", "08:00:00", "16:00:00", "8")
      period = create_period!(dept, ~D[2026-04-01], ~D[2026-04-30])

      _req = create_requirement!(period, day_shift, ~D[2026-04-01], 1)
      _p1 = create_profile!(emp1, dept)

      {:ok, result} = Runner.run(period.id)
      version = result.version

      assert {:ok, check_result} = Runner.pre_publish_check(version.id)
      assert check_result.publishable == true
      assert check_result.errors == []
    end
  end
end
