# 护士排班域（Scheduling）seed 数据
# 场景：某三甲医院 4 个科室的 2026 年 4 月排班
# 运行: mix run priv/repo/seeds/scheduling_seeds.exs

alias UniboExPoc.Scheduling.{
  Department,
  Employee,
  ShiftType,
  SchedulingPeriod,
  ScheduleVersion,
  SolverRun,
  MedicalStaffProfile,
  ShiftPreference,
  CoverageRequirement,
  ShiftAssignment,
  SchedulingConstraint,
  ConstraintViolation
}

# ── 科室（跨域引用副本，无 :create action，直接 Repo 插入） ──

dept_neike = UniboExPoc.Repo.insert!(%Department{id: Ash.UUID.generate(), name: "内科"})
dept_waike = UniboExPoc.Repo.insert!(%Department{id: Ash.UUID.generate(), name: "外科"})
dept_icu = UniboExPoc.Repo.insert!(%Department{id: Ash.UUID.generate(), name: "ICU"})
dept_jizhen = UniboExPoc.Repo.insert!(%Department{id: Ash.UUID.generate(), name: "急诊科"})

# ── 护士（跨域引用副本，无 :create action，直接 Repo 插入） ──

nurse_zhang = UniboExPoc.Repo.insert!(%Employee{id: Ash.UUID.generate(), employee_code: "N001", name: "张护士"})
nurse_li = UniboExPoc.Repo.insert!(%Employee{id: Ash.UUID.generate(), employee_code: "N002", name: "李护士"})
nurse_wang = UniboExPoc.Repo.insert!(%Employee{id: Ash.UUID.generate(), employee_code: "N003", name: "王护士"})
nurse_zhao = UniboExPoc.Repo.insert!(%Employee{id: Ash.UUID.generate(), employee_code: "N004", name: "赵护士"})
nurse_liu = UniboExPoc.Repo.insert!(%Employee{id: Ash.UUID.generate(), employee_code: "N005", name: "刘护士"})
nurse_chen = UniboExPoc.Repo.insert!(%Employee{id: Ash.UUID.generate(), employee_code: "N006", name: "陈护士"})

# ── 班次类型（ICU 科室） ─────────────────────────────────────

shift_day =
  ShiftType
  |> Ash.Changeset.for_create(:create, %{
    code: "day",
    name: "白班",
    start_time: "08:00",
    end_time: "16:00",
    duration_hours: Decimal.new("8.0"),
    is_night: false,
    color: "#4CAF50",
    sort_order: 1,
    enabled: true,
    department_id: dept_icu.id
  })
  |> Ash.create!()

shift_evening =
  ShiftType
  |> Ash.Changeset.for_create(:create, %{
    code: "evening",
    name: "中班",
    start_time: "16:00",
    end_time: "00:00",
    duration_hours: Decimal.new("8.0"),
    is_night: false,
    color: "#FF9800",
    sort_order: 2,
    enabled: true,
    department_id: dept_icu.id
  })
  |> Ash.create!()

shift_night =
  ShiftType
  |> Ash.Changeset.for_create(:create, %{
    code: "night",
    name: "夜班",
    start_time: "00:00",
    end_time: "08:00",
    duration_hours: Decimal.new("8.0"),
    is_night: true,
    color: "#3F51B5",
    sort_order: 3,
    enabled: true,
    department_id: dept_icu.id
  })
  |> Ash.create!()

# ── 医护画像 ─────────────────────────────────────────────────

_profile_zhang =
  MedicalStaffProfile
  |> Ash.Changeset.for_create(:create, %{
    maturity_score: Decimal.new("85.0"),
    can_lead_shift: true,
    work_restrictions: nil,
    overtime_willing: true,
    notes: "10年 ICU 经验，可带班",
    employee_id: nurse_zhang.id,
    department_id: dept_icu.id
  })
  |> Ash.create!()

_profile_li =
  MedicalStaffProfile
  |> Ash.Changeset.for_create(:create, %{
    maturity_score: Decimal.new("72.0"),
    can_lead_shift: false,
    work_restrictions: %{"type" => "pregnant", "note" => "孕期，不排夜班"},
    overtime_willing: false,
    notes: "孕期护士，限制夜班",
    employee_id: nurse_li.id,
    department_id: dept_icu.id
  })
  |> Ash.create!()

_profile_wang =
  MedicalStaffProfile
  |> Ash.Changeset.for_create(:create, %{
    maturity_score: Decimal.new("60.0"),
    can_lead_shift: false,
    work_restrictions: nil,
    overtime_willing: true,
    notes: "新入职护士",
    employee_id: nurse_wang.id,
    department_id: dept_icu.id
  })
  |> Ash.create!()

_profile_zhao =
  MedicalStaffProfile
  |> Ash.Changeset.for_create(:create, %{
    maturity_score: Decimal.new("90.0"),
    can_lead_shift: true,
    work_restrictions: nil,
    overtime_willing: true,
    notes: "护士长，全能型",
    employee_id: nurse_zhao.id,
    department_id: dept_icu.id
  })
  |> Ash.create!()

_profile_liu =
  MedicalStaffProfile
  |> Ash.Changeset.for_create(:create, %{
    maturity_score: Decimal.new("78.0"),
    can_lead_shift: true,
    work_restrictions: nil,
    overtime_willing: false,
    notes: "资深护士",
    employee_id: nurse_liu.id,
    department_id: dept_icu.id
  })
  |> Ash.create!()

_profile_chen =
  MedicalStaffProfile
  |> Ash.Changeset.for_create(:create, %{
    maturity_score: Decimal.new("55.0"),
    can_lead_shift: false,
    work_restrictions: nil,
    overtime_willing: true,
    notes: "实习转正护士",
    employee_id: nurse_chen.id,
    department_id: dept_icu.id
  })
  |> Ash.create!()

# ── 约束规则（ICU 科室） ─────────────────────────────────────

_constraint_rest =
  SchedulingConstraint
  |> Ash.Changeset.for_create(:create, %{
    name: "夜班后休息",
    constraint_type: :hard,
    category: :rest_after_night,
    params: %{"rest_hours" => 12},
    weight: 100,
    enabled: true,
    notes: "夜班后至少休息12小时",
    department_id: dept_icu.id
  })
  |> Ash.create!()

_constraint_consecutive_night =
  SchedulingConstraint
  |> Ash.Changeset.for_create(:create, %{
    name: "连续夜班上限",
    constraint_type: :hard,
    category: :limit_consecutive_nights,
    params: %{"max_consecutive" => 2},
    weight: 100,
    enabled: true,
    notes: "连续夜班不超过2天",
    department_id: dept_icu.id
  })
  |> Ash.create!()

_constraint_max_days =
  SchedulingConstraint
  |> Ash.Changeset.for_create(:create, %{
    name: "连续上班天数限制",
    constraint_type: :hard,
    category: :max_consecutive_days,
    params: %{"max_days" => 6},
    weight: 100,
    enabled: true,
    notes: "连续上班不超过6天",
    department_id: dept_icu.id
  })
  |> Ash.create!()

_constraint_leave =
  SchedulingConstraint
  |> Ash.Changeset.for_create(:create, %{
    name: "尊重请假",
    constraint_type: :hard,
    category: :respect_leave,
    params: %{},
    weight: 100,
    enabled: true,
    notes: "已批准的请假不能安排排班",
    department_id: dept_icu.id
  })
  |> Ash.create!()

_constraint_fair_night =
  SchedulingConstraint
  |> Ash.Changeset.for_create(:create, %{
    name: "夜班公平分配",
    constraint_type: :soft,
    category: :fair_night_distribution,
    params: %{"max_deviation" => 2},
    weight: 80,
    enabled: true,
    notes: "同科室护士夜班数差异不超过2天",
    department_id: dept_icu.id
  })
  |> Ash.create!()

_constraint_preference =
  SchedulingConstraint
  |> Ash.Changeset.for_create(:create, %{
    name: "尊重个人偏好",
    constraint_type: :soft,
    category: :respect_preference,
    params: %{},
    weight: 40,
    enabled: true,
    notes: "尽量满足护士班次偏好",
    department_id: dept_icu.id
  })
  |> Ash.create!()

_constraint_lead =
  SchedulingConstraint
  |> Ash.Changeset.for_create(:create, %{
    name: "每班带班覆盖",
    constraint_type: :hard,
    category: :lead_coverage,
    params: %{},
    weight: 100,
    enabled: true,
    notes: "每个班次至少有一名可带班护士",
    department_id: dept_icu.id
  })
  |> Ash.create!()

# ── 排班周期（ICU 2026年4月） ────────────────────────────────

period_icu_apr =
  SchedulingPeriod
  |> Ash.Changeset.for_create(:create, %{
    start_date: ~D[2026-04-01],
    end_date: ~D[2026-04-30],
    title: "ICU 2026-04 月排班",
    notes: "4月排班计划",
    generation_mode: :blank,
    department_id: dept_icu.id
  })
  |> Ash.create!()

# ── 排班偏好 ─────────────────────────────────────────────────

_pref_zhang =
  ShiftPreference
  |> Ash.Changeset.for_create(:create, %{
    preferred_shift_tags: %{"prefer" => ["day"]},
    unavailable_dates: %{"dates" => ["2026-04-05", "2026-04-06"]},
    max_night_shifts: 8,
    notes: "清明节休假",
    employee_id: nurse_zhang.id
  })
  |> Ash.create!()

_pref_li =
  ShiftPreference
  |> Ash.Changeset.for_create(:create, %{
    preferred_shift_tags: %{"prefer" => ["day", "evening"]},
    unavailable_dates: %{"dates" => []},
    max_night_shifts: 0,
    notes: "孕期不排夜班",
    employee_id: nurse_li.id
  })
  |> Ash.create!()

_pref_wang =
  ShiftPreference
  |> Ash.Changeset.for_create(:create, %{
    preferred_shift_tags: %{},
    unavailable_dates: %{"dates" => ["2026-04-15"]},
    max_night_shifts: 10,
    notes: nil,
    employee_id: nurse_wang.id
  })
  |> Ash.create!()

# ── 覆盖需求（4月1日~3日样例） ───────────────────────────────

# 4月1日白班
cov_0401_day =
  CoverageRequirement
  |> Ash.Changeset.for_create(:create, %{
    requirement_date: ~D[2026-04-01],
    role_code: "duty_nurse",
    role_name: "值班护士",
    required_skill_tags: %{"tags" => ["ICU"]},
    min_headcount: 3,
    target_headcount: 4,
    required_lead_count: 1,
    priority: 100,
    notes: "工作日白班标准配置",
    period_id: period_icu_apr.id,
    shift_type_id: shift_day.id
  })
  |> Ash.create!()

# 4月1日夜班
cov_0401_night =
  CoverageRequirement
  |> Ash.Changeset.for_create(:create, %{
    requirement_date: ~D[2026-04-01],
    role_code: "duty_nurse",
    role_name: "值班护士",
    required_skill_tags: %{"tags" => ["ICU"]},
    min_headcount: 2,
    target_headcount: 2,
    required_lead_count: 1,
    priority: 100,
    notes: "夜班标准配置",
    period_id: period_icu_apr.id,
    shift_type_id: shift_night.id
  })
  |> Ash.create!()

# 4月2日白班
cov_0402_day =
  CoverageRequirement
  |> Ash.Changeset.for_create(:create, %{
    requirement_date: ~D[2026-04-02],
    role_code: "duty_nurse",
    role_name: "值班护士",
    required_skill_tags: %{"tags" => ["ICU"]},
    min_headcount: 3,
    target_headcount: 4,
    required_lead_count: 1,
    priority: 100,
    notes: "工作日白班标准配置",
    period_id: period_icu_apr.id,
    shift_type_id: shift_day.id
  })
  |> Ash.create!()

# 4月3日白班（周末减配）
_cov_0403_day =
  CoverageRequirement
  |> Ash.Changeset.for_create(:create, %{
    requirement_date: ~D[2026-04-03],
    role_code: "duty_nurse",
    role_name: "值班护士",
    required_skill_tags: %{"tags" => ["ICU"]},
    min_headcount: 2,
    target_headcount: 3,
    required_lead_count: 1,
    priority: 100,
    notes: "周末白班减配",
    period_id: period_icu_apr.id,
    shift_type_id: shift_day.id
  })
  |> Ash.create!()

# ── 排班版本 ─────────────────────────────────────────────────

version_v1 =
  ScheduleVersion
  |> Ash.Changeset.for_create(:create, %{
    version_no: 1,
    change_summary: "初始自动排班结果",
    period_id: period_icu_apr.id
  })
  |> Ash.create!()

_version_v2 =
  ScheduleVersion
  |> Ash.Changeset.for_create(:create, %{
    version_no: 2,
    change_summary: "人工调整后版本",
    period_id: period_icu_apr.id
  })
  |> Ash.create!()

# ── 求解运行 ─────────────────────────────────────────────────

solver_run_1 =
  SolverRun
  |> Ash.Changeset.for_create(:create, %{
    engine_type: "greedy_local_search",
    seed: 42,
    timeout_ms: 30000,
    input_snapshot: %{
      "department" => "ICU",
      "period" => "2026-04",
      "nurses" => 6,
      "constraints" => 7,
      "coverage_requirements" => 4
    },
    period_id: period_icu_apr.id
  })
  |> Ash.create!()

# ── 排班分配（4月1日~2日样例） ───────────────────────────────

# 4月1日白班：张护士（带班）、王护士、陈护士
_assign_0401_day_zhang =
  ShiftAssignment
  |> Ash.Changeset.for_create(:create, %{
    starts_at: ~U[2026-04-01T00:00:00Z],
    ends_at: ~U[2026-04-01T08:00:00Z],
    source: :auto,
    is_locked: false,
    notes: "带班",
    period_id: period_icu_apr.id,
    requirement_id: cov_0401_day.id,
    version_id: version_v1.id,
    employee_id: nurse_zhang.id
  })
  |> Ash.create!()

_assign_0401_day_wang =
  ShiftAssignment
  |> Ash.Changeset.for_create(:create, %{
    starts_at: ~U[2026-04-01T00:00:00Z],
    ends_at: ~U[2026-04-01T08:00:00Z],
    source: :auto,
    is_locked: false,
    notes: nil,
    period_id: period_icu_apr.id,
    requirement_id: cov_0401_day.id,
    version_id: version_v1.id,
    employee_id: nurse_wang.id
  })
  |> Ash.create!()

_assign_0401_day_chen =
  ShiftAssignment
  |> Ash.Changeset.for_create(:create, %{
    starts_at: ~U[2026-04-01T00:01:00Z],
    ends_at: ~U[2026-04-01T08:01:00Z],
    source: :auto,
    is_locked: false,
    notes: nil,
    period_id: period_icu_apr.id,
    requirement_id: cov_0401_day.id,
    version_id: version_v1.id,
    employee_id: nurse_chen.id
  })
  |> Ash.create!()

# 4月1日夜班：赵护士（带班）、刘护士
_assign_0401_night_zhao =
  ShiftAssignment
  |> Ash.Changeset.for_create(:create, %{
    starts_at: ~U[2026-04-01T16:00:00Z],
    ends_at: ~U[2026-04-02T00:00:00Z],
    source: :auto,
    is_locked: true,
    notes: "带班，已锁定",
    period_id: period_icu_apr.id,
    requirement_id: cov_0401_night.id,
    version_id: version_v1.id,
    employee_id: nurse_zhao.id
  })
  |> Ash.create!()

_assign_0401_night_liu =
  ShiftAssignment
  |> Ash.Changeset.for_create(:create, %{
    starts_at: ~U[2026-04-01T16:00:00Z],
    ends_at: ~U[2026-04-02T00:00:00Z],
    source: :auto,
    is_locked: false,
    notes: nil,
    period_id: period_icu_apr.id,
    requirement_id: cov_0401_night.id,
    version_id: version_v1.id,
    employee_id: nurse_liu.id
  })
  |> Ash.create!()

# 4月2日白班：李护士、王护士、陈护士（人工调换）
_assign_0402_day_li =
  ShiftAssignment
  |> Ash.Changeset.for_create(:create, %{
    starts_at: ~U[2026-04-02T00:00:00Z],
    ends_at: ~U[2026-04-02T08:00:00Z],
    source: :manual,
    is_locked: false,
    notes: "人工指定（孕期仅白班）",
    period_id: period_icu_apr.id,
    requirement_id: cov_0402_day.id,
    version_id: version_v1.id,
    employee_id: nurse_li.id
  })
  |> Ash.create!()

_assign_0402_day_wang =
  ShiftAssignment
  |> Ash.Changeset.for_create(:create, %{
    starts_at: ~U[2026-04-02T00:00:00Z],
    ends_at: ~U[2026-04-02T08:00:00Z],
    source: :auto,
    is_locked: false,
    notes: nil,
    period_id: period_icu_apr.id,
    requirement_id: cov_0402_day.id,
    version_id: version_v1.id,
    employee_id: nurse_wang.id
  })
  |> Ash.create!()

# ── 约束违反 ─────────────────────────────────────────────────

_violation_warning =
  ConstraintViolation
  |> Ash.Changeset.for_create(:create, %{
    rule_code: "fair_night_distribution",
    severity: :warning,
    message: "张护士夜班数(4)与王护士(2)差异为2，达到上限",
    details_json: %{
      "employee_a" => "N001",
      "employee_b" => "N003",
      "night_count_a" => 4,
      "night_count_b" => 2,
      "deviation" => 2
    },
    period_id: period_icu_apr.id,
    version_id: version_v1.id
  })
  |> Ash.create!()

IO.puts("✅ Scheduling seeds 完成: 4 科室, 6 护士, 3 班次类型, 1 排班周期, 7 约束规则, 4 覆盖需求, 7 排班分配, 1 违反记录")
