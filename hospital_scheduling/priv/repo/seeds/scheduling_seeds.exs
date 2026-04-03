# 护士排班系统种子数据 — 真实排班场景
#
# 运行方式：mix run hospital_scheduling/priv/repo/seeds/scheduling_seeds.exs
#
# 数据集：
# - 4 个科室：心内科 / 骨科 / 急诊科 / ICU
# - 3 种班次：白班 8:00-16:00 / 小夜班 16:00-24:00 / 大夜班 0:00-8:00
# - 4 名护士：张护士 / 李护士 / 王护士 / 赵护士
# - 排班周期：2026年3月第4周 (03/23 - 03/29)
# - 约束：每人每周不超过5班，夜班后必须休息
# - 完整排班分配 + 求解运行 + 约束违反记录

alias HospitalScheduling.Scheduling
require Logger

Logger.info("开始创建排班种子数据...")

# ── 1. 科室 ──────────────────────────────────────────────────

dept_specs = [
  {"心内科", "cardiology"},
  {"骨科", "orthopedics"},
  {"急诊科", "emergency"},
  {"ICU", "icu"}
]

departments = Enum.map(dept_specs, fn {name, _code} ->
  id = Ash.UUID.generate()
  {:ok, bin_id} = Ecto.UUID.dump(id)
  {:ok, _} = Ecto.Adapters.SQL.query(HospitalScheduling.Repo,
    "INSERT INTO scheduling_departments (id, name) VALUES ($1, $2)
     ON CONFLICT (id) DO NOTHING", [bin_id, name])
  {:ok, dept} = Ash.get(Scheduling.Department, id, authorize?: false)
  Logger.info("  科室: #{dept.name}")
  dept
end)

# 主要使用心内科做完整排班演示
primary_dept = Enum.at(departments, 0)

# ── 2. 护士 ──────────────────────────────────────────────────

nurse_data = [
  {"N001", "张护士"},
  {"N002", "李护士"},
  {"N003", "王护士"},
  {"N004", "赵护士"}
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

[zhang, li, wang, zhao] = employees

# ── 3. 班次类型（每个科室创建3种班次）─────────────────────────

shift_specs = [
  {"day",     "白班",   "08:00:00", "16:00:00", "8", false, "#4CAF50", 1},
  {"evening", "小夜班", "16:00:00", "23:59:00", "8", false, "#FF9800", 2},
  {"night",   "大夜班", "00:00:00", "08:00:00", "8", true,  "#9C27B0", 3}
]

# 为心内科创建班次
shift_types = Enum.map(shift_specs, fn {code, name, start_t, end_t, hours, is_night, color, sort} ->
  {:ok, st} = Ash.create(Scheduling.ShiftType, %{
    department_id: primary_dept.id,
    code: code,
    name: name,
    start_time: start_t,
    end_time: end_t,
    duration_hours: Decimal.new(hours),
    is_night: is_night,
    color: color,
    sort_order: sort
  }, authorize?: false)
  Logger.info("  班次: #{st.name} (#{st.code}) #{start_t}-#{end_t}")
  st
end)

[day_shift, evening_shift, night_shift] = shift_types

# ── 4. 护士能力档案 ──────────────────────────────────────────

# 张护士和李护士可带班，赵护士愿意加班
profiles = [
  {zhang, 85, true, [], false},
  {li,    78, true, [], false},
  {wang,  65, false, [], false},
  {zhao,  60, false, [], true}
]

Enum.each(profiles, fn {emp, score, can_lead, restrictions, overtime} ->
  {:ok, _} = Ash.create(Scheduling.MedicalStaffProfile, %{
    employee_id: emp.id,
    department_id: primary_dept.id,
    maturity_score: Decimal.new("#{score}"),
    can_lead_shift: can_lead,
    work_restrictions: restrictions,
    overtime_willing: overtime
  }, authorize?: false)
end)

Logger.info("  能力档案: 4人（2名可带班）")

# ── 5. 约束规则 ──────────────────────────────────────────────

constraints_data = [
  {:rest_after_night, :hard, "夜班后必须休息", ~s({"min_rest_hours": 12}), 0,
   "大夜班结束后至少休息12小时，不可接白班"},
  {:max_consecutive_days, :hard, "每周最多5班", ~s({"max_shifts_per_week": 5}), 0,
   "每人每周排班不超过5个班次"},
  {:lead_coverage, :hard, "每班至少1名带班护士", ~s({"min_leads": 1}), 0,
   "确保每个班次有带班能力的护士值班"},
  {:fair_night_distribution, :soft, "夜班公平分配", ~s({"max_deviation": 2}), 80,
   "夜班在全科护士间均匀分配，偏差不超过2个"},
  {:respect_preference, :soft, "尊重护士偏好", ~s({}), 40,
   "尽量满足护士提交的班次偏好和不可用日期"}
]

Enum.each(constraints_data, fn {cat, type, name, params, weight, notes} ->
  {:ok, _} = Ash.create(Scheduling.SchedulingConstraint, %{
    department_id: primary_dept.id,
    name: name,
    category: cat,
    constraint_type: type,
    params: params,
    weight: weight,
    enabled: true,
    notes: notes
  }, authorize?: false)
  Logger.info("  约束: [#{type}] #{name}")
end)

# ── 6. 排班周期：2026年3月第4周 ──────────────────────────────

# 心内科 — 已生成
{:ok, period_cardiology} = Ash.create(Scheduling.SchedulingPeriod, %{
  department_id: primary_dept.id,
  start_date: ~D[2026-03-23],
  end_date: ~D[2026-03-29],
  title: "心内科 2026-03 第4周排班"
}, authorize?: false)
Logger.info("  排班周期: #{period_cardiology.title}")

# 骨科 — 草稿
{:ok, period_ortho} = Ash.create(Scheduling.SchedulingPeriod, %{
  department_id: Enum.at(departments, 1).id,
  start_date: ~D[2026-03-23],
  end_date: ~D[2026-03-29],
  title: "骨科 2026-03 第4周排班"
}, authorize?: false)
Logger.info("  排班周期: #{period_ortho.title}")

# 急诊科 — 草稿
{:ok, period_er} = Ash.create(Scheduling.SchedulingPeriod, %{
  department_id: Enum.at(departments, 2).id,
  start_date: ~D[2026-03-23],
  end_date: ~D[2026-03-29],
  title: "急诊科 2026-03 第4周排班"
}, authorize?: false)
Logger.info("  排班周期: #{period_er.title}")

# ICU — 草稿
{:ok, period_icu} = Ash.create(Scheduling.SchedulingPeriod, %{
  department_id: Enum.at(departments, 3).id,
  start_date: ~D[2026-03-23],
  end_date: ~D[2026-03-29],
  title: "ICU 2026-03 第4周排班"
}, authorize?: false)
Logger.info("  排班周期: #{period_icu.title}")

# ── 6b. ICU 班次类型 + 覆盖需求 ──────────────────────────────
# ICU 也需要完整的班次和需求数据，否则 Solver 跑不了

icu_dept = Enum.at(departments, 3)

icu_shift_types = Enum.map(shift_specs, fn {code, name, start_t, end_t, hours, is_night, color, sort} ->
  {:ok, st} = Ash.create(Scheduling.ShiftType, %{
    department_id: icu_dept.id,
    code: code,
    name: name,
    start_time: start_t,
    end_time: end_t,
    duration_hours: Decimal.new(hours),
    is_night: is_night,
    color: color,
    sort_order: sort
  }, authorize?: false)
  st
end)

Logger.info("  ICU 班次: #{length(icu_shift_types)} 种")

# ICU 覆盖需求（7天 × 3班次，ICU 人力需求比心内科高）
icu_requirements = for day_offset <- 0..6, st <- icu_shift_types do
  date = Date.add(~D[2026-03-23], day_offset)
  is_weekend = Date.day_of_week(date) in [6, 7]

  {min_hc, target_hc} = cond do
    st.code == "day" and not is_weekend -> {3, 4}
    st.code == "day" and is_weekend -> {2, 3}
    st.code == "evening" and not is_weekend -> {2, 3}
    st.code == "evening" and is_weekend -> {2, 2}
    st.code == "night" and not is_weekend -> {2, 3}
    st.code == "night" and is_weekend -> {2, 2}
  end

  {:ok, req} = Ash.create(Scheduling.CoverageRequirement, %{
    period_id: period_icu.id,
    shift_type_id: st.id,
    requirement_date: date,
    role_code: "nurse",
    role_name: "护士",
    min_headcount: min_hc,
    target_headcount: target_hc,
    required_lead_count: 1,
    priority: 100
  }, authorize?: false)
  req
end

Logger.info("  ICU 需求: #{length(icu_requirements)} 条（7天 × 3班次）")

# ── 7. 覆盖需求（心内科，7天 × 3班次）────────────────────────

# 工作日：白班3人(目标4)/小夜2人(目标3)/大夜2人
# 周末：白班2人(目标3)/小夜2人/大夜1人(目标2)
requirements = for day_offset <- 0..6, st <- shift_types do
  date = Date.add(~D[2026-03-23], day_offset)
  is_weekend = Date.day_of_week(date) in [6, 7]

  {min_hc, target_hc} = cond do
    st.code == "day" and not is_weekend -> {3, 4}
    st.code == "day" and is_weekend -> {2, 3}
    st.code == "evening" and not is_weekend -> {2, 3}
    st.code == "evening" and is_weekend -> {2, 2}
    st.code == "night" and not is_weekend -> {2, 2}
    st.code == "night" and is_weekend -> {1, 2}
  end

  {:ok, req} = Ash.create(Scheduling.CoverageRequirement, %{
    period_id: period_cardiology.id,
    shift_type_id: st.id,
    requirement_date: date,
    role_code: "nurse",
    role_name: "护士",
    min_headcount: min_hc,
    target_headcount: target_hc,
    required_lead_count: 1,
    priority: 100
  }, authorize?: false)
  req
end

Logger.info("  需求: #{length(requirements)} 条（7天 × 3班次）")

# ── 8. 护士偏好 ──────────────────────────────────────────────

# 张护士偏好白班
{:ok, _} = Ash.create(Scheduling.ShiftPreference, %{
  employee_id: zhang.id,
  period_id: period_cardiology.id,
  preferred_shift_tags: ["day"],
  max_night_shifts: 1,
  notes: "家中有幼儿，希望尽量安排白班"
}, authorize?: false)

# 赵护士周四不可用
{:ok, _} = Ash.create(Scheduling.ShiftPreference, %{
  employee_id: zhao.id,
  period_id: period_cardiology.id,
  unavailable_dates: ["2026-03-26"],
  notes: "周四有进修培训"
}, authorize?: false)

Logger.info("  偏好: 2条")

# ── 9. 求解运行 ──────────────────────────────────────────────

{:ok, solver_run} = Ash.create(Scheduling.SolverRun, %{
  period_id: period_cardiology.id,
  engine_type: "cp_sat",
  timeout_ms: 30000,
  input_snapshot: %{
    "department" => "心内科",
    "period" => "2026-03-23 ~ 2026-03-29",
    "employees" => 4,
    "shift_types" => 3,
    "constraints" => 5
  }
}, authorize?: false)

Logger.info("  求解运行: #{solver_run.id}")

# ── 10. 版本 ─────────────────────────────────────────────────

{:ok, version} = Ash.create(Scheduling.ScheduleVersion, %{
  period_id: period_cardiology.id,
  version_no: 1,
  origin_type: :solver,
  change_summary: "求解器自动生成初始排班方案"
}, authorize?: false)

Logger.info("  版本: v#{version.version_no}")

# ── 11. 排班分配（心内科，完整一周）──────────────────────────
#
# 排班表（符合约束：每人每周<=5班，夜班后休息）：
#        周一  周二  周三  周四  周五  周六  周日
# 张护士  白    白    小夜  休    白    大夜  休     = 5班
# 李护士  小夜  大夜  休    白    白    小夜  休     = 5班
# 王护士  大夜  休    白    白    小夜  休    白     = 5班
# 赵护士  休    小夜  大夜  休    大夜  休    小夜   = 4班（周四培训）

# 排班矩阵：[{护士, 日期偏移, 班次}]
assignment_matrix = [
  # 张护士
  {zhang, 0, day_shift},     {zhang, 1, day_shift},     {zhang, 2, evening_shift},
  {zhang, 4, day_shift},     {zhang, 5, night_shift},
  # 李护士
  {li, 0, evening_shift},    {li, 1, night_shift},      {li, 3, day_shift},
  {li, 4, day_shift},        {li, 5, evening_shift},
  # 王护士
  {wang, 0, night_shift},    {wang, 2, day_shift},      {wang, 3, day_shift},
  {wang, 4, evening_shift},  {wang, 6, day_shift},
  # 赵护士（周四休息/培训）
  {zhao, 1, evening_shift},  {zhao, 2, night_shift},    {zhao, 4, night_shift},
  {zhao, 6, evening_shift}
]

assignments = Enum.map(assignment_matrix, fn {emp, day_offset, shift} ->
  date = Date.add(~D[2026-03-23], day_offset)

  # 根据班次类型计算 UTC 时间
  {starts_at, ends_at} = cond do
    shift.code == "day" ->
      {NaiveDateTime.new!(date, ~T[00:00:00]), NaiveDateTime.new!(date, ~T[08:00:00])}
    shift.code == "evening" ->
      {NaiveDateTime.new!(date, ~T[08:00:00]), NaiveDateTime.new!(date, ~T[16:00:00])}
    shift.code == "night" ->
      {NaiveDateTime.new!(date, ~T[16:00:00]),
       NaiveDateTime.new!(Date.add(date, 1), ~T[00:00:00])}
  end

  # 查找对应需求
  req = Enum.find(requirements, fn r ->
    r.shift_type_id == shift.id and r.requirement_date == date
  end)

  {:ok, asgn} = Ash.create(Scheduling.ShiftAssignment, %{
    period_id: period_cardiology.id,
    version_id: version.id,
    requirement_id: req.id,
    employee_id: emp.id,
    starts_at: starts_at,
    ends_at: ends_at,
    source: :auto
  }, authorize?: false)
  asgn
end)

Logger.info("  排班分配: #{length(assignments)} 条")

# ── 12. 约束违反记录 ─────────────────────────────────────────

# 赵护士夜班偏多（3个），触发公平分配警告
{:ok, _} = Ash.create(Scheduling.ConstraintViolation, %{
  period_id: period_cardiology.id,
  version_id: version.id,
  rule_code: "fair_night_distribution",
  severity: :warning,
  message: "赵护士本周夜班3个，超出公平分配偏差阈值",
  details_json: %{
    "employee" => "赵护士",
    "night_count" => 3,
    "average" => 1.75,
    "max_deviation" => 2
  }
}, authorize?: false)

# 张护士偏好白班但被分配了小夜班
zhao_wed_assignment = Enum.find(assignments, fn a ->
  a.employee_id == zhang.id and
    NaiveDateTime.to_date(a.starts_at) == ~D[2026-03-25]
end)

{:ok, _} = Ash.create(Scheduling.ConstraintViolation, %{
  period_id: period_cardiology.id,
  version_id: version.id,
  assignment_id: if(zhao_wed_assignment, do: zhao_wed_assignment.id, else: nil),
  rule_code: "respect_preference",
  severity: :warning,
  message: "张护士偏好白班，但周三被分配小夜班",
  details_json: %{
    "employee" => "张护士",
    "preferred" => "day",
    "assigned" => "evening",
    "date" => "2026-03-25"
  }
}, authorize?: false)

Logger.info("  约束违反: 2条（均为警告）")

Logger.info("""

种子数据创建完成！

  科室: 心内科 / 骨科 / 急诊科 / ICU
  护士: 张护士 / 李护士 / 王护士 / 赵护士
  班次: 白班(8:00-16:00) / 小夜班(16:00-24:00) / 大夜班(0:00-8:00)
  约束: 3硬 + 2软
  周期: 2026-03-23 ~ 2026-03-29（4个科室）
  需求: #{length(requirements)} 条（心内科完整需求）
  排班: #{length(assignments)} 条（心内科完整一周排班）
  违反: 2条警告

排班规则验证：
  - 每人每周不超过5班 ✓
  - 夜班后必须休息 ✓（大夜后次日均为休息）
  - 赵护士周四不排班 ✓（培训日）
""")
