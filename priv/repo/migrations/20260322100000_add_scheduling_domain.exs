defmodule UniboExPoc.Repo.Migrations.AddSchedulingDomain do
  @moduledoc """
  护士排班域（Scheduling）全部表结构。
  包含 12 个实体：Department、Employee、ShiftType、SchedulingPeriod、
  ScheduleVersion、SolverRun、MedicalStaffProfile、ShiftPreference、
  CoverageRequirement、ShiftAssignment、SchedulingConstraint、ConstraintViolation。
  """

  use Ecto.Migration

  def up do
    # ── 基础引用表（跨域引用的本地副本） ──────────────────────

    create table(:scheduling_departments, primary_key: false) do
      add(:id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true)
      add(:name, :text)
    end

    create table(:scheduling_employees, primary_key: false) do
      add(:id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true)
      add(:employee_code, :text)
      add(:name, :text)
    end

    # ── 班次类型 ──────────────────────────────────────────────

    create table(:scheduling_shift_types, primary_key: false) do
      add(:id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true)
      add(:code, :text, null: false)
      add(:name, :text, null: false)
      add(:start_time, :text, null: false)
      add(:end_time, :text, null: false)
      add(:duration_hours, :decimal, null: false)
      add(:is_night, :boolean, null: false, default: false)
      add(:color, :text)
      add(:sort_order, :integer, null: false, default: 0)
      add(:enabled, :boolean, null: false, default: true)

      timestamps(type: :utc_datetime_usec, inserted_at: :inserted_at, updated_at: :updated_at)

      add(:department_id,
        references(:scheduling_departments,
          column: :id,
          name: "scheduling_shift_types_department_id_fkey",
          type: :uuid,
          prefix: "public"
        ),
        null: false
      )
    end

    create unique_index(:scheduling_shift_types, [:department_id, :code],
      name: "idx_scheduling_shift_types_unique_dept_shift_code"
    )

    # ── 求解运行（先建，SchedulingPeriod 会引用它） ──────────

    create table(:scheduling_solver_runs, primary_key: false) do
      add(:id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true)
      add(:status, :text, null: false, default: "pending")
      add(:engine_type, :text, null: false, default: "greedy_local_search")
      add(:seed, :integer)
      add(:timeout_ms, :integer, null: false, default: 30000)
      add(:started_at, :utc_datetime_usec)
      add(:completed_at, :utc_datetime_usec)
      add(:score, :decimal)
      add(:hard_violation_count, :integer, null: false, default: 0)
      add(:warning_count, :integer, null: false, default: 0)
      add(:input_snapshot, :map, null: false, default: %{})
      add(:output_snapshot, :map)
      add(:error_message, :text)

      timestamps(type: :utc_datetime_usec, inserted_at: :inserted_at, updated_at: :updated_at)

      # period_id 稍后通过 alter 添加（循环引用）
    end

    # ── 排班版本（先建，SchedulingPeriod 会引用它） ───────────

    create table(:scheduling_schedule_versions, primary_key: false) do
      add(:id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true)
      add(:version_no, :integer, null: false)
      add(:status, :text, null: false, default: "working")
      add(:origin_type, :text, null: false, default: "manual")
      add(:created_by, :uuid)
      add(:change_summary, :text)

      timestamps(type: :utc_datetime_usec, inserted_at: :inserted_at, updated_at: :updated_at)

      # period_id 稍后通过 alter 添加（循环引用）
    end

    # ── 排班周期 ──────────────────────────────────────────────

    create table(:scheduling_periods, primary_key: false) do
      add(:id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true)
      add(:start_date, :date, null: false)
      add(:end_date, :date, null: false)
      add(:state, :text, null: false, default: "draft")
      add(:title, :text)
      add(:generation_mode, :text, null: false, default: "blank")
      add(:notes, :text)

      timestamps(type: :utc_datetime_usec, inserted_at: :inserted_at, updated_at: :updated_at)

      add(:department_id,
        references(:scheduling_departments,
          column: :id,
          name: "scheduling_periods_department_id_fkey",
          type: :uuid,
          prefix: "public"
        ),
        null: false
      )

      add(:source_period_id,
        references(:scheduling_periods,
          column: :id,
          name: "scheduling_periods_source_period_id_fkey",
          type: :uuid,
          prefix: "public"
        )
      )

      add(:source_version_id,
        references(:scheduling_schedule_versions,
          column: :id,
          name: "scheduling_periods_source_version_id_fkey",
          type: :uuid,
          prefix: "public"
        )
      )

      add(:current_version_id,
        references(:scheduling_schedule_versions,
          column: :id,
          name: "scheduling_periods_current_version_id_fkey",
          type: :uuid,
          prefix: "public"
        )
      )

      add(:published_version_id,
        references(:scheduling_schedule_versions,
          column: :id,
          name: "scheduling_periods_published_version_id_fkey",
          type: :uuid,
          prefix: "public"
        )
      )

      add(:last_solver_run_id,
        references(:scheduling_solver_runs,
          column: :id,
          name: "scheduling_periods_last_solver_run_id_fkey",
          type: :uuid,
          prefix: "public"
        )
      )
    end

    # ── 回填循环引用外键 ─────────────────────────────────────

    alter table(:scheduling_solver_runs) do
      add(:period_id,
        references(:scheduling_periods,
          column: :id,
          name: "scheduling_solver_runs_period_id_fkey",
          type: :uuid,
          prefix: "public"
        ),
        null: false
      )
    end

    alter table(:scheduling_schedule_versions) do
      add(:period_id,
        references(:scheduling_periods,
          column: :id,
          name: "scheduling_schedule_versions_period_id_fkey",
          type: :uuid,
          prefix: "public"
        ),
        null: false
      )

      add(:based_on_run_id,
        references(:scheduling_solver_runs,
          column: :id,
          name: "scheduling_schedule_versions_based_on_run_id_fkey",
          type: :uuid,
          prefix: "public"
        )
      )

      add(:source_version_id,
        references(:scheduling_schedule_versions,
          column: :id,
          name: "scheduling_schedule_versions_source_version_id_fkey",
          type: :uuid,
          prefix: "public"
        )
      )
    end

    create unique_index(:scheduling_schedule_versions, [:period_id, :version_no],
      name: "idx_scheduling_schedule_versions_unique_period_version_no"
    )

    # ── 医护画像 ──────────────────────────────────────────────

    create table(:scheduling_medical_staff_profiles, primary_key: false) do
      add(:id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true)
      add(:maturity_score, :decimal, null: false, default: 0)
      add(:can_lead_shift, :boolean, null: false, default: false)
      add(:work_restrictions, :map)
      add(:overtime_willing, :boolean, null: false, default: false)
      add(:notes, :text)

      timestamps(type: :utc_datetime_usec, inserted_at: :inserted_at, updated_at: :updated_at)

      add(:employee_id,
        references(:scheduling_employees,
          column: :id,
          name: "scheduling_medical_staff_profiles_employee_id_fkey",
          type: :uuid,
          prefix: "public"
        ),
        null: false
      )

      add(:department_id,
        references(:scheduling_departments,
          column: :id,
          name: "scheduling_medical_staff_profiles_department_id_fkey",
          type: :uuid,
          prefix: "public"
        ),
        null: false
      )
    end

    create unique_index(:scheduling_medical_staff_profiles, [:employee_id, :department_id],
      name: "idx_scheduling_medical_staff_profiles_unique_employee_fd7e3b5a"
    )

    # ── 排班偏好 ──────────────────────────────────────────────

    create table(:scheduling_shift_preferences, primary_key: false) do
      add(:id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true)
      add(:preferred_shift_tags, :map)
      add(:unavailable_dates, :map)
      add(:max_night_shifts, :integer)
      add(:notes, :text)

      timestamps(type: :utc_datetime_usec, inserted_at: :inserted_at, updated_at: :updated_at)

      add(:employee_id,
        references(:scheduling_employees,
          column: :id,
          name: "scheduling_shift_preferences_employee_id_fkey",
          type: :uuid,
          prefix: "public"
        ),
        null: false
      )

      add(:period_id,
        references(:scheduling_periods,
          column: :id,
          name: "scheduling_shift_preferences_period_id_fkey",
          type: :uuid,
          prefix: "public"
        )
      )
    end

    # ── 覆盖需求 ──────────────────────────────────────────────

    create table(:scheduling_coverage_requirements, primary_key: false) do
      add(:id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true)
      add(:requirement_date, :date, null: false)
      add(:role_code, :text, null: false)
      add(:role_name, :text)
      add(:required_skill_tags, :map)
      add(:min_headcount, :integer, null: false)
      add(:target_headcount, :integer)
      add(:required_lead_count, :integer, null: false, default: 0)
      add(:priority, :integer, null: false, default: 100)
      add(:notes, :text)

      timestamps(type: :utc_datetime_usec, inserted_at: :inserted_at, updated_at: :updated_at)

      add(:period_id,
        references(:scheduling_periods,
          column: :id,
          name: "scheduling_coverage_requirements_period_id_fkey",
          type: :uuid,
          prefix: "public"
        ),
        null: false
      )

      add(:shift_type_id,
        references(:scheduling_shift_types,
          column: :id,
          name: "scheduling_coverage_requirements_shift_type_id_fkey",
          type: :uuid,
          prefix: "public"
        ),
        null: false
      )
    end

    create unique_index(:scheduling_coverage_requirements, [:period_id, :requirement_date, :shift_type_id, :role_code],
      name: "idx_scheduling_coverage_requirements_unique_period_dat_461f704c"
    )

    # ── 排班分配 ──────────────────────────────────────────────

    create table(:scheduling_shift_assignments, primary_key: false) do
      add(:id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true)
      add(:starts_at, :utc_datetime_usec, null: false)
      add(:ends_at, :utc_datetime_usec, null: false)
      add(:source, :text, null: false, default: "auto")
      add(:is_locked, :boolean, null: false, default: false)
      add(:notes, :text)

      timestamps(type: :utc_datetime_usec, inserted_at: :inserted_at, updated_at: :updated_at)

      add(:period_id,
        references(:scheduling_periods,
          column: :id,
          name: "scheduling_shift_assignments_period_id_fkey",
          type: :uuid,
          prefix: "public"
        ),
        null: false
      )

      add(:requirement_id,
        references(:scheduling_coverage_requirements,
          column: :id,
          name: "scheduling_shift_assignments_requirement_id_fkey",
          type: :uuid,
          prefix: "public"
        ),
        null: false
      )

      add(:version_id,
        references(:scheduling_schedule_versions,
          column: :id,
          name: "scheduling_shift_assignments_version_id_fkey",
          type: :uuid,
          prefix: "public"
        ),
        null: false
      )

      add(:employee_id,
        references(:scheduling_employees,
          column: :id,
          name: "scheduling_shift_assignments_employee_id_fkey",
          type: :uuid,
          prefix: "public"
        ),
        null: false
      )

      add(:baseline_run_id,
        references(:scheduling_solver_runs,
          column: :id,
          name: "scheduling_shift_assignments_baseline_run_id_fkey",
          type: :uuid,
          prefix: "public"
        )
      )
    end

    create unique_index(:scheduling_shift_assignments, [:period_id, :employee_id, :starts_at],
      name: "idx_scheduling_shift_assignments_unique_period_employee_start"
    )

    create unique_index(:scheduling_shift_assignments, [:version_id, :requirement_id, :employee_id, :starts_at],
      name: "idx_scheduling_shift_assignments_unique_version_req_em_834b770a"
    )

    # ── 约束规则 ──────────────────────────────────────────────

    create table(:scheduling_constraints, primary_key: false) do
      add(:id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true)
      add(:name, :text, null: false)
      add(:constraint_type, :text, null: false)
      add(:category, :text, null: false)
      add(:params, :map, null: false, default: %{})
      add(:weight, :integer, default: 50)
      add(:enabled, :boolean, null: false, default: true)
      add(:notes, :text)

      timestamps(type: :utc_datetime_usec, inserted_at: :inserted_at, updated_at: :updated_at)

      add(:department_id,
        references(:scheduling_departments,
          column: :id,
          name: "scheduling_constraints_department_id_fkey",
          type: :uuid,
          prefix: "public"
        ),
        null: false
      )
    end

    # ── 约束违反 ──────────────────────────────────────────────

    create table(:scheduling_constraint_violations, primary_key: false) do
      add(:id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true)
      add(:rule_code, :text, null: false)
      add(:severity, :text, null: false)
      add(:message, :text, null: false)
      add(:details_json, :map, null: false, default: %{})
      add(:inserted_at, :utc_datetime_usec, null: false, default: fragment("now()"))

      add(:period_id,
        references(:scheduling_periods,
          column: :id,
          name: "scheduling_constraint_violations_period_id_fkey",
          type: :uuid,
          prefix: "public"
        ),
        null: false
      )

      add(:version_id,
        references(:scheduling_schedule_versions,
          column: :id,
          name: "scheduling_constraint_violations_version_id_fkey",
          type: :uuid,
          prefix: "public"
        ),
        null: false
      )

      add(:assignment_id,
        references(:scheduling_shift_assignments,
          column: :id,
          name: "scheduling_constraint_violations_assignment_id_fkey",
          type: :uuid,
          prefix: "public"
        )
      )

      add(:requirement_id,
        references(:scheduling_coverage_requirements,
          column: :id,
          name: "scheduling_constraint_violations_requirement_id_fkey",
          type: :uuid,
          prefix: "public"
        )
      )
    end

    # ── Paper Trail 版本表 ────────────────────────────────────

    version_tables = [
      :scheduling_shift_types_versions,
      :scheduling_periods_versions,
      :scheduling_schedule_versions_versions,
      :scheduling_solver_runs_versions,
      :scheduling_medical_staff_profiles_versions,
      :scheduling_shift_preferences_versions,
      :scheduling_coverage_requirements_versions,
      :scheduling_shift_assignments_versions,
      :scheduling_constraints_versions,
      :scheduling_constraint_violations_versions
    ]

    for tbl <- version_tables do
      create table(tbl, primary_key: false) do
        add(:id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true)
        add(:version_source_id, :uuid, null: false)
        add(:version_action_name, :text)
        add(:version_action_type, :text)
        add(:changes, :map)
        add(:version_inserted_at, :utc_datetime_usec, null: false, default: fragment("now()"))
        add(:version_updated_at, :utc_datetime_usec, null: false, default: fragment("now()"))
      end
    end
  end

  def down do
    version_tables = [
      :scheduling_constraint_violations_versions,
      :scheduling_constraints_versions,
      :scheduling_shift_assignments_versions,
      :scheduling_coverage_requirements_versions,
      :scheduling_shift_preferences_versions,
      :scheduling_medical_staff_profiles_versions,
      :scheduling_solver_runs_versions,
      :scheduling_schedule_versions_versions,
      :scheduling_periods_versions,
      :scheduling_shift_types_versions
    ]

    for tbl <- version_tables do
      drop_if_exists table(tbl)
    end

    drop_if_exists table(:scheduling_constraint_violations)
    drop_if_exists table(:scheduling_constraints)
    drop_if_exists table(:scheduling_shift_assignments)
    drop_if_exists table(:scheduling_coverage_requirements)
    drop_if_exists table(:scheduling_shift_preferences)
    drop_if_exists table(:scheduling_medical_staff_profiles)

    # 先删循环引用外键再删表
    alter table(:scheduling_schedule_versions) do
      remove :period_id
      remove :based_on_run_id
      remove :source_version_id
    end

    alter table(:scheduling_solver_runs) do
      remove :period_id
    end

    drop_if_exists table(:scheduling_periods)
    drop_if_exists table(:scheduling_schedule_versions)
    drop_if_exists table(:scheduling_solver_runs)
    drop_if_exists table(:scheduling_shift_types)
    drop_if_exists table(:scheduling_employees)
    drop_if_exists table(:scheduling_departments)
  end
end
