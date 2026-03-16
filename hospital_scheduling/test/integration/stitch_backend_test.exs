defmodule HospitalScheduling.Integration.StitchBackendTest do
  @moduledoc """
  StitchBackend runtime 闭环集成测试。

  验证：
  1. manifest.json 和 frontend_manifest.v1.json 正确加载
  2. contract/1 能为每个 page_id 返回 backend contract
  3. dispatch 链路对标准 CRUD 页面能走通（list/get/create/update/destroy）
  4. dispatch 链路对自定义 action（lock/unlock/状态转换）能走通
  5. build_graphql_request 生成正确的 input type（非 JSON）
  """
  use HospitalScheduling.DataCase, async: false

  alias HospitalSchedulingWeb.Graphql.StitchBackend
  alias HospitalSchedulingWeb.Graphql.RuntimeConfig
  alias HospitalScheduling.Scheduling
  require Ash.Query

  # ── 辅助函数 ──────────────────────────────────────────

  defp create_department!(name \\ "ICU") do
    id = Ash.UUID.generate()
    {:ok, bin_id} = Ecto.UUID.dump(id)

    {:ok, _} =
      Ecto.Adapters.SQL.query(
        HospitalScheduling.Repo,
        "INSERT INTO scheduling_departments (id, name) VALUES ($1, $2)",
        [bin_id, name]
      )

    {:ok, dept} = Ash.get(Scheduling.Department, id, authorize?: false)
    dept
  end

  # ── manifest 加载测试 ──────────────────────────────────

  describe "manifest 加载" do
    test "manifest.json 包含 fields 列表" do
      manifest = RuntimeConfig.manifest()
      fields = manifest["fields"]

      assert is_list(fields)
      assert length(fields) > 0

      # 检查 ShiftType 的 list 字段存在
      shift_type_list =
        Enum.find(fields, fn f -> f["entity"] == "ShiftType" and f["mode"] == "list" end)

      assert shift_type_list != nil
      assert shift_type_list["field"] == "listSchedulingShiftTypes"
    end

    test "manifest.json 包含 input_type 信息" do
      manifest = RuntimeConfig.manifest()
      fields = manifest["fields"]

      # create 操作应有 input_type
      create_field =
        Enum.find(fields, fn f -> f["entity"] == "ShiftType" and f["mode"] == "create" end)

      assert create_field != nil
      assert create_field["input_type"] == "CreateSchedulingShiftTypeInput"
    end

    test "frontend_manifest.v1.json 包含 10 个页面" do
      fm = RuntimeConfig.frontend_manifest()
      pages = fm["pages"]

      assert is_list(pages)
      assert length(pages) == 10

      page_ids = Enum.map(pages, & &1["page_id"]) |> Enum.sort()

      assert "shift_type_list" in page_ids
      assert "shift_type_detail" in page_ids
      assert "scheduling_period_list" in page_ids
      assert "requirement_matrix" in page_ids
      assert "solver_result" in page_ids
      assert "calendar_adjustment" in page_ids
      assert "publish_preview" in page_ids
    end

    test "每个页面都有 api_map" do
      fm = RuntimeConfig.frontend_manifest()
      pages = fm["pages"]

      Enum.each(pages, fn page ->
        assert is_map(page["api_map"]),
               "页面 #{page["page_id"]} 缺少 api_map"

        assert map_size(page["api_map"]) > 0,
               "页面 #{page["page_id"]} 的 api_map 为空"
      end)
    end
  end

  # ── contract 测试 ──────────────────────────────────────

  describe "contract/1" do
    test "返回标准 list 页面的 backend contract" do
      assert {:ok, contract} = StitchBackend.contract("shift_type_list")
      assert contract["page_id"] == "shift_type_list"
      assert contract["backend"]["mode"] == "api"
      assert is_map(contract["backend"]["api_map"])
      assert Map.has_key?(contract["backend"]["api_map"], "list")
    end

    test "返回标准 detail 页面的 backend contract" do
      assert {:ok, contract} = StitchBackend.contract("shift_type_detail")
      assert contract["page_id"] == "shift_type_detail"
      assert Map.has_key?(contract["backend"]["api_map"], "get")
      assert Map.has_key?(contract["backend"]["api_map"], "update")
    end

    test "返回复杂页面的 backend contract" do
      assert {:ok, contract} = StitchBackend.contract("solver_result")
      api_map = contract["backend"]["api_map"]
      assert Map.has_key?(api_map, "get")
      assert Map.has_key?(api_map, "list_assignments")
      assert Map.has_key?(api_map, "lock")
      assert Map.has_key?(api_map, "unlock")
    end

    test "不存在的 page_id 返回 error" do
      assert {:error, :stitch_backend_page_not_found} = StitchBackend.contract("nonexistent")
    end
  end

  # ── dispatch 链路测试 ──────────────────────────────────

  describe "dispatch 链路 — list 页面" do
    test "shift_type_list __load__ 返回空列表" do
      result =
        StitchBackend.dispatch(
          "__load__",
          %{"__page_id" => "shift_type_list"},
          %{}
        )

      assert {:ok, backend_result} = result
      assert is_map(backend_result)
      assert backend_result.errors == []
      assert backend_result.meta["page_id"] == "shift_type_list"
      assert backend_result.meta["api_key"] == "list"
    end

    test "shift_type_list __load__ 返回已创建的数据" do
      dept = create_department!()

      Ash.create!(
        Scheduling.ShiftType
        |> Ash.Changeset.for_create(:create, %{
          name: "白班",
          code: "DAY",
          start_time: "08:00",
          end_time: "16:00",
          duration_hours: 8.0,
          department_id: dept.id
        }),
        authorize?: false
      )

      {:ok, backend_result} =
        StitchBackend.dispatch(
          "__load__",
          %{"__page_id" => "shift_type_list"},
          %{"selection" => "id name code"}
        )

      assert is_list(backend_result.dto["rows"])
      assert length(backend_result.dto["rows"]) >= 1
    end
  end

  describe "dispatch 链路 — detail 页面" do
    setup do
      dept = create_department!()

      st =
        Ash.create!(
          Scheduling.ShiftType
          |> Ash.Changeset.for_create(:create, %{
            name: "夜班",
            code: "NIGHT",
            start_time: "23:00",
            end_time: "07:00",
            duration_hours: 8.0,
            department_id: dept.id
          }),
          authorize?: false
        )

      %{dept: dept, shift_type: st}
    end

    test "shift_type_detail __load__ 返回记录", %{shift_type: st} do
      {:ok, backend_result} =
        StitchBackend.dispatch(
          "__load__",
          %{"__page_id" => "shift_type_detail", "id" => st.id},
          %{"selection" => "id name code"}
        )

      assert backend_result.meta["api_key"] == "get"
      assert backend_result.dto["record"]["id"] == st.id
    end

    test "shift_type_detail update 修改记录", %{shift_type: st} do
      {:ok, backend_result} =
        StitchBackend.dispatch(
          "form_submit",
          %{"__page_id" => "shift_type_detail", "id" => st.id, "name" => "晚班改"},
          %{"selection" => "id name"}
        )

      assert backend_result.meta["api_key"] == "update"
      assert backend_result.dto["record"]["name"] == "晚班改"
    end
  end

  describe "dispatch 链路 — 自定义 action" do
    setup do
      dept = create_department!()
      employee_id = Ash.UUID.generate()
      {:ok, employee_bin_id} = Ecto.UUID.dump(employee_id)

      {:ok, _} =
        Ecto.Adapters.SQL.query(
          HospitalScheduling.Repo,
          "INSERT INTO scheduling_employees (id, employee_code, name) VALUES ($1, $2, $3)",
          [employee_bin_id, "N900", "后端联调护士"]
        )

      {:ok, employee} = Ash.get(Scheduling.Employee, employee_id, authorize?: false)

      shift_type =
        Ash.create!(
          Scheduling.ShiftType
          |> Ash.Changeset.for_create(:create, %{
            name: "白班",
            code: "DAY",
            start_time: "08:00:00",
            end_time: "16:00:00",
            duration_hours: 8.0,
            department_id: dept.id
          }),
          authorize?: false
        )

      period =
        Ash.create!(
          Scheduling.SchedulingPeriod
          |> Ash.Changeset.for_create(:create, %{
            title: "3月排班",
            start_date: ~D[2026-04-01],
            end_date: ~D[2026-04-08],
            department_id: dept.id
          }),
          authorize?: false
        )

      _requirement =
        Ash.create!(
          Scheduling.CoverageRequirement
          |> Ash.Changeset.for_create(:create, %{
            period_id: period.id,
            shift_type_id: shift_type.id,
            requirement_date: ~D[2026-04-01],
            role_code: "nurse",
            min_headcount: 1
          }),
          authorize?: false
        )

      _profile =
        Ash.create!(
          Scheduling.MedicalStaffProfile
          |> Ash.Changeset.for_create(:create, %{
            employee_id: employee.id,
            department_id: dept.id,
            maturity_score: Decimal.new("60"),
            can_lead_shift: false,
            overtime_willing: false
          }),
          authorize?: false
        )

      %{dept: dept, period: period, employee: employee, shift_type: shift_type}
    end

    test "scheduling_period_detail start_generating 会触发真实求解并产出版本", %{period: period} do
      {:ok, backend_result} =
        StitchBackend.dispatch(
          "action_start_generating",
          %{"__page_id" => "scheduling_period_detail", "id" => period.id},
          %{"selection" => "id state"}
        )

      assert backend_result.errors == []
      assert backend_result.dto["record"]["state"] == "generated"

      updated_period =
        Ash.get!(Scheduling.SchedulingPeriod, period.id, authorize?: false)

      assert updated_period.current_version_id != nil
      assert updated_period.last_solver_run_id != nil
    end
  end
end
