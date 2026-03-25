# 护士排班系统 V1 种子数据
#
# 运行方式：mix run priv/repo/seeds.exs
#
# 创建最小验证数据集：
# - 1 个科室（ICU）
# - 3 种班次（白班/小夜/大夜）
# - 10 名护士（2 名可带班）
# - 3 条约束（夜班休息、最大连续天数、带班覆盖）
# - 1 个排班周期（7 天）
# - 每天 3 班 × 每班 2 人需求

alias HospitalScheduling.Scheduling
require Logger

Logger.info("🏥 开始创建种子数据...")

# ── 1. 科室 ──────────────────────────────────────────────

dept_id = Ash.UUID.generate()
{:ok, bin_dept_id} = Ecto.UUID.dump(dept_id)
{:ok, _} = Ecto.Adapters.SQL.query(HospitalScheduling.Repo,
  "INSERT INTO scheduling_departments (id, name) VALUES ($1, $2)
   ON CONFLICT (id) DO NOTHING", [bin_dept_id, "ICU"])
{:ok, dept} = Ash.get(Scheduling.Department, dept_id, authorize?: false)
Logger.info("  科室: #{dept.name} (#{dept.id})")

# ── 2. 护士 ──────────────────────────────────────────────

nurse_data = [
  {"N001", "张三"},   {"N002", "李四"},   {"N003", "王五"},
  {"N004", "赵六"},   {"N005", "陈七"},   {"N006", "周八"},
  {"N007", "吴九"},   {"N008", "郑十"},   {"N009", "刘十一"},
  {"N010", "孙十二"}
]

employees = Enum.map(nurse_data, fn {code, name} ->
  id = Ash.UUID.generate()
  {:ok, bin_id} = Ecto.UUID.dump(id)
  {:ok, _} = Ecto.Adapters.SQL.query(HospitalScheduling.Repo,
    "INSERT INTO scheduling_employees (id, employee_code, name) VALUES ($1, $2, $3)
     ON CONFLICT (id) DO NOTHING", [bin_id, code, name])
  {:ok, emp} = Ash.get(Scheduling.Employee, id, authorize?: false)
  Logger.info("  护士: #{emp.name} (#{emp.employee_code})")
  emp
end)

# ── 3. 班次类型 ──────────────────────────────────────────

shift_specs = [
  {"day",     "白班",   "08:00:00", "16:00:00", "8", false, "#4CAF50", 1},
  {"evening", "小夜班", "16:00:00", "23:59:00", "8", false, "#FF9800", 2},
  {"night",   "大夜班", "00:00:00", "08:00:00", "8", true,  "#9C27B0", 3}
]

shift_types = Enum.map(shift_specs, fn {code, name, start_t, end_t, hours, is_night, color, sort} ->
  {:ok, st} = Ash.create(Scheduling.ShiftType, %{
    department_id: dept.id,
    code: code,
    name: name,
    start_time: start_t,
    end_time: end_t,
    duration_hours: Decimal.new(hours),
    is_night: is_night,
    color: color,
    sort_order: sort
  }, authorize?: false)
  Logger.info("  班次: #{st.name} (#{st.code}) #{st.start_time}-#{st.end_time}")
  st
end)

# ── 4. 护士能力档案 ─────────────────────────────────────

# 前 2 名可带班，第 9 名孕期限制
profiles = Enum.with_index(employees, 1) |> Enum.map(fn {emp, i} ->
  {:ok, p} = Ash.create(Scheduling.MedicalStaffProfile, %{
    employee_id: emp.id,
    department_id: dept.id,
    maturity_score: Decimal.new("#{30 + i * 7}"),
    can_lead_shift: i in [1, 2],
    work_restrictions: if(i == 9, do: ["pregnant"], else: nil),
    overtime_willing: i in [3, 5, 7]
  }, authorize?: false)
  p
end)

lead_count = Enum.count(profiles, & &1.can_lead_shift)
Logger.info("  能力档案: #{length(profiles)} 人（#{lead_count} 名可带班）")

# ── 5. 约束规则 ──────────────────────────────────────────

constraints = [
  {:rest_after_night, :hard, "夜班后必须休息 12 小时", ~s({"min_rest_hours": 12}), 0},
  {:max_consecutive_days, :hard, "连续工作不超过 6 天", ~s({"max_days": 6}), 0},
  {:lead_coverage, :hard, "每班至少 1 名带班护士", ~s({"min_leads": 1}), 0},
  {:fair_night_distribution, :soft, "夜班公平分配", ~s({"max_deviation": 2}), 80},
  {:respect_preference, :soft, "尊重班次偏好", ~s({}), 40}
]

Enum.each(constraints, fn {cat, type, name, params, weight} ->
  {:ok, _} = Ash.create(Scheduling.SchedulingConstraint, %{
    department_id: dept.id,
    name: name,
    category: cat,
    constraint_type: type,
    params: params,
    weight: weight,
    enabled: true
  }, authorize?: false)
  Logger.info("  约束: [#{type}] #{name}")
end)

# ── 6. 排班周期（2026-04-01 ~ 2026-04-07） ──────────────

{:ok, period} = Ash.create(Scheduling.SchedulingPeriod, %{
  department_id: dept.id,
  start_date: ~D[2026-04-01],
  end_date: ~D[2026-04-07],
  title: "ICU 2026-04 第一周排班"
}, authorize?: false)
Logger.info("  排班周期: #{period.title}")

# ── 7. 每天需求（3 班 × 每班 2 人） ─────────────────────

requirements = for day_offset <- 0..6,
    st <- shift_types do
  date = Date.add(~D[2026-04-01], day_offset)
  {:ok, req} = Ash.create(Scheduling.CoverageRequirement, %{
    period_id: period.id,
    shift_type_id: st.id,
    requirement_date: date,
    role_code: "nurse",
    min_headcount: 2,
    required_lead_count: 0,
    priority: 100
  }, authorize?: false)
  req
end

Logger.info("  需求: #{length(requirements)} 条（7 天 × 3 班 × 每班 2 人）")

# ── 8. 偏好和请假 ────────────────────────────────────────

# 护士 1 偏好白班，限制最多 2 个夜班
{:ok, _} = Ash.create(Scheduling.ShiftPreference, %{
  employee_id: Enum.at(employees, 0).id,
  period_id: period.id,
  preferred_shift_tags: ["day"],
  max_night_shifts: 2
}, authorize?: false)

# 护士 6 请假 4月3日、4月5日
{:ok, _} = Ash.create(Scheduling.ShiftPreference, %{
  employee_id: Enum.at(employees, 5).id,
  period_id: period.id,
  unavailable_dates: ["2026-04-03", "2026-04-05"]
}, authorize?: false)

# 护士 9（孕期）偏好白班
{:ok, _} = Ash.create(Scheduling.ShiftPreference, %{
  employee_id: Enum.at(employees, 8).id,
  period_id: period.id,
  preferred_shift_tags: ["day"],
  max_night_shifts: 0
}, authorize?: false)

Logger.info("  偏好/请假: 3 条")

Logger.info("""

✅ 种子数据创建完成！

  科室: ICU
  护士: 10 人（2 名可带班，1 名孕期限制）
  班次: 白班 / 小夜班 / 大夜班
  约束: 3 硬 + 2 软
  周期: 2026-04-01 ~ 2026-04-07
  需求: #{length(requirements)} 条
  偏好: 3 条

下一步：
  mix run priv/repo/scripts/demo.exs   # 运行完整演示
""")
