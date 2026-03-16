defmodule HospitalScheduling.Integration.GraphqlFlowTest do
  @moduledoc """
  V1 主链路 GraphQL API 集成测试。

  通过 Absinthe.run/3 直接执行 GraphQL query/mutation，
  验证前端实际调用的 API 层能正确工作。

  覆盖：
  1. 创建班次类型 → 查询列表
  2. 创建排班周期 → 创建需求 → 查询需求列表
  3. 锁定/解锁 assignment
  4. 排班周期状态流转（draft → generating → generated）
  5. 查询 constraint violations
  """
  use HospitalScheduling.DataCase, async: false

  alias HospitalScheduling.Scheduling
  require Ash.Query

  @schema HospitalSchedulingWeb.Generated.Schema.Scheduling

  # ── 辅助函数 ──────────────────────────────────────────

  defp run_graphql(query, variables \\ %{}) do
    Absinthe.run(query, @schema, variables: variables)
  end

  defp create_department!(name \\ "ICU") do
    id = Ash.UUID.generate()
    {:ok, bin_id} = Ecto.UUID.dump(id)
    {:ok, _} = Ecto.Adapters.SQL.query(HospitalScheduling.Repo,
      "INSERT INTO scheduling_departments (id, name) VALUES ($1, $2)", [bin_id, name])
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

  # ── 测试 ──────────────────────────────────────────────

  describe "班次类型 CRUD" do
    test "通过 GraphQL 创建班次类型并查询列表" do
      dept = create_department!()

      create_mutation = """
      mutation($input: CreateSchedulingShiftTypeInput!) {
        createSchedulingShiftType(input: $input) {
          result {
            id
            code
            name
            startTime
            endTime
            durationHours
            isNight
          }
          errors { message }
        }
      }
      """

      {:ok, result} = run_graphql(create_mutation, %{
        "input" => %{
          "departmentId" => dept.id,
          "code" => "day",
          "name" => "白班",
          "startTime" => "08:00:00",
          "endTime" => "16:00:00",
          "durationHours" => "8",
          "isNight" => false
        }
      })

      assert result[:errors] == nil
      shift_type = get_in(result, [:data, "createSchedulingShiftType", "result"])
      assert shift_type["code"] == "day"
      assert shift_type["name"] == "白班"
      assert shift_type["isNight"] == false
      shift_type_id = shift_type["id"]

      # 查询列表
      list_query = """
      query {
        listSchedulingShiftTypes {
          results {
            id
            code
            name
          }
          count
        }
      }
      """

      {:ok, list_result} = run_graphql(list_query)
      assert list_result[:errors] == nil
      types = get_in(list_result, [:data, "listSchedulingShiftTypes", "results"])
      assert length(types) >= 1
      assert Enum.any?(types, fn t -> t["id"] == shift_type_id end)
    end
  end

  describe "排班周期 + 需求创建" do
    test "创建周期 → 创建覆盖需求 → 查询需求列表" do
      dept = create_department!("内科")

      {:ok, shift_type} = Ash.create(Scheduling.ShiftType, %{
        department_id: dept.id,
        code: "day",
        name: "白班",
        start_time: "08:00:00",
        end_time: "16:00:00",
        duration_hours: Decimal.new("8"),
        is_night: false
      }, authorize?: false)

      # 通过 GraphQL 创建排班周期
      create_period = """
      mutation($input: CreateSchedulingSchedulingPeriodInput!) {
        createSchedulingSchedulingPeriod(input: $input) {
          result {
            id
            title
            startDate
            endDate
            state
          }
          errors { message }
        }
      }
      """

      {:ok, period_result} = run_graphql(create_period, %{
        "input" => %{
          "departmentId" => dept.id,
          "startDate" => "2026-04-01",
          "endDate" => "2026-04-07",
          "title" => "内科四月第一周"
        }
      })

      assert period_result[:errors] == nil
      period = get_in(period_result, [:data, "createSchedulingSchedulingPeriod", "result"])
      assert period["title"] == "内科四月第一周"
      assert period["state"] == "draft"
      period_id = period["id"]

      # 通过 GraphQL 创建覆盖需求
      create_req = """
      mutation($input: CreateSchedulingCoverageRequirementInput!) {
        createSchedulingCoverageRequirement(input: $input) {
          result {
            id
            requirementDate
            roleCode
            minHeadcount
          }
          errors { message }
        }
      }
      """

      {:ok, req_result} = run_graphql(create_req, %{
        "input" => %{
          "periodId" => period_id,
          "shiftTypeId" => shift_type.id,
          "requirementDate" => "2026-04-01",
          "roleCode" => "nurse",
          "minHeadcount" => 3,
          "priority" => 100
        }
      })

      assert req_result[:errors] == nil
      req = get_in(req_result, [:data, "createSchedulingCoverageRequirement", "result"])
      assert req["minHeadcount"] == 3
      assert req["roleCode"] == "nurse"

      # 查询需求列表
      list_reqs = """
      query {
        listSchedulingCoverageRequirements {
          results {
            id
            requirementDate
            minHeadcount
          }
          count
        }
      }
      """

      {:ok, list_result} = run_graphql(list_reqs)
      assert list_result[:errors] == nil
      reqs = get_in(list_result, [:data, "listSchedulingCoverageRequirements", "results"])
      assert length(reqs) >= 1
    end
  end

  describe "排班周期状态流转" do
    test "draft → start_generating 会直接触发求解并落库版本" do
      dept = create_department!("外科")
      emp = create_employee!("N100", "自动排班测试护士")

      {:ok, shift_type} = Ash.create(Scheduling.ShiftType, %{
        department_id: dept.id,
        code: "day",
        name: "白班",
        start_time: "08:00:00",
        end_time: "16:00:00",
        duration_hours: Decimal.new("8"),
        is_night: false
      }, authorize?: false)

      {:ok, period} = Ash.create(Scheduling.SchedulingPeriod, %{
        department_id: dept.id,
        start_date: ~D[2026-04-01],
        end_date: ~D[2026-04-07],
        title: "外科状态测试"
      }, authorize?: false)

      {:ok, _req} = Ash.create(Scheduling.CoverageRequirement, %{
        period_id: period.id,
        shift_type_id: shift_type.id,
        requirement_date: ~D[2026-04-01],
        role_code: "nurse",
        min_headcount: 1
      }, authorize?: false)

      {:ok, _profile} = Ash.create(Scheduling.MedicalStaffProfile, %{
        employee_id: emp.id,
        department_id: dept.id,
        maturity_score: Decimal.new("60"),
        can_lead_shift: false
      }, authorize?: false)

      assert period.state == :draft

      # start_generating: 直接传 id，无 input
      start_gen = """
      mutation($id: ID!) {
        startGeneratingSchedulingSchedulingPeriod(id: $id) {
          result {
            id
            state
          }
          errors { message }
        }
      }
      """

      {:ok, gen_result} = run_graphql(start_gen, %{"id" => period.id})

      assert gen_result[:errors] == nil
      updated = get_in(gen_result, [:data, "startGeneratingSchedulingSchedulingPeriod", "result"])
      assert updated["state"] == "generated"

      updated_period = Ash.get!(Scheduling.SchedulingPeriod, period.id, authorize?: false)
      assert updated_period.current_version_id != nil
      assert updated_period.last_solver_run_id != nil
    end
  end

  describe "ShiftAssignment 锁定/解锁" do
    test "通过 GraphQL 锁定和解锁 assignment" do
      dept = create_department!("儿科")
      emp = create_employee!("N001", "张三")

      {:ok, shift_type} = Ash.create(Scheduling.ShiftType, %{
        department_id: dept.id,
        code: "day",
        name: "白班",
        start_time: "08:00:00",
        end_time: "16:00:00",
        duration_hours: Decimal.new("8")
      }, authorize?: false)

      {:ok, period} = Ash.create(Scheduling.SchedulingPeriod, %{
        department_id: dept.id,
        start_date: ~D[2026-04-01],
        end_date: ~D[2026-04-07],
        title: "儿科锁定测试"
      }, authorize?: false)

      {:ok, req} = Ash.create(Scheduling.CoverageRequirement, %{
        period_id: period.id,
        shift_type_id: shift_type.id,
        requirement_date: ~D[2026-04-01],
        role_code: "nurse",
        min_headcount: 1
      }, authorize?: false)

      {:ok, version} = Ash.create(Scheduling.ScheduleVersion, %{
        period_id: period.id,
        version_no: 1,
        origin_type: :manual
      }, authorize?: false)

      {:ok, assignment} = Ash.create(Scheduling.ShiftAssignment, %{
        period_id: period.id,
        requirement_id: req.id,
        version_id: version.id,
        employee_id: emp.id,
        starts_at: ~U[2026-04-01 08:00:00Z],
        ends_at: ~U[2026-04-01 16:00:00Z],
        source: :manual
      }, authorize?: false)

      assert assignment.is_locked == false

      # 锁定: 直接传 id，无 input
      lock_mutation = """
      mutation($id: ID!) {
        lockSchedulingShiftAssignment(id: $id) {
          result {
            id
            isLocked
          }
          errors { message }
        }
      }
      """

      {:ok, lock_result} = run_graphql(lock_mutation, %{"id" => assignment.id})

      assert lock_result[:errors] == nil
      locked = get_in(lock_result, [:data, "lockSchedulingShiftAssignment", "result"])
      assert locked["isLocked"] == true

      # 解锁: 直接传 id
      unlock_mutation = """
      mutation($id: ID!) {
        unlockSchedulingShiftAssignment(id: $id) {
          result {
            id
            isLocked
          }
          errors { message }
        }
      }
      """

      {:ok, unlock_result} = run_graphql(unlock_mutation, %{"id" => assignment.id})

      assert unlock_result[:errors] == nil
      unlocked = get_in(unlock_result, [:data, "unlockSchedulingShiftAssignment", "result"])
      assert unlocked["isLocked"] == false
    end
  end

  describe "ConstraintViolation 查询" do
    test "求解后通过 GraphQL 查询 violation 列表" do
      dept = create_department!("急诊")
      emp = create_employee!("N001", "李四")

      {:ok, shift_type} = Ash.create(Scheduling.ShiftType, %{
        department_id: dept.id,
        code: "day",
        name: "白班",
        start_time: "08:00:00",
        end_time: "16:00:00",
        duration_hours: Decimal.new("8")
      }, authorize?: false)

      {:ok, _profile} = Ash.create(Scheduling.MedicalStaffProfile, %{
        employee_id: emp.id,
        department_id: dept.id,
        maturity_score: Decimal.new("50"),
        can_lead_shift: false
      }, authorize?: false)

      {:ok, period} = Ash.create(Scheduling.SchedulingPeriod, %{
        department_id: dept.id,
        start_date: ~D[2026-04-01],
        end_date: ~D[2026-04-07],
        title: "急诊 violation 测试"
      }, authorize?: false)

      # 需要 3 人但只有 1 人 → 产生 violation
      {:ok, _req} = Ash.create(Scheduling.CoverageRequirement, %{
        period_id: period.id,
        shift_type_id: shift_type.id,
        requirement_date: ~D[2026-04-01],
        role_code: "nurse",
        min_headcount: 3
      }, authorize?: false)

      # 运行 solver（直接调用，前端会通过 API 触发）
      {:ok, _result} = HospitalScheduling.Solver.Runner.run(period.id, seed: 42)

      # 通过 GraphQL 查询 violations
      list_violations = """
      query {
        listSchedulingConstraintViolations {
          results {
            id
            ruleCode
            severity
            message
          }
          count
        }
      }
      """

      {:ok, viol_result} = run_graphql(list_violations)
      assert viol_result[:errors] == nil
      violations = get_in(viol_result, [:data, "listSchedulingConstraintViolations", "results"])
      assert length(violations) > 0

      # 至少有一个 coverage_missing error
      assert Enum.any?(violations, fn v ->
        v["ruleCode"] == "coverage_missing" and v["severity"] == "error"
      end)
    end
  end
end
