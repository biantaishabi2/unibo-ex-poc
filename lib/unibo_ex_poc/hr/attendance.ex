# Workflow: attendance_write_flow — Attendance 写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   check_out --> [*]
# ```
defmodule UniboExPoc.HR.Attendance do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "考勤记录"
  end

  postgres do
    table "hr_attendances"
    repo UniboExPoc.Repo
  end

  graphql do
    type :hr_attendance

    queries do
      get :get_hr_attendance, :read
      list :list_hr_attendances, :read
    end

    mutations do
      create :create_hr_attendance, :create
      update :check_out_hr_attendance, :check_out
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :check_in, :utc_datetime do
      allow_nil? false
      public? true
      description "签到时间"
    end
    attribute :check_out, :utc_datetime do
      public? true
      description "签退时间"
    end
    attribute :worked_hours, :decimal do
      public? true
      description "工作时长（小时）= check_out - check_in - lunch_intervals"
    end
    attribute :overtime_hours, :decimal do
      public? true
      description "加班时长（小时）= worked_hours - planned_hours，应用 threshold 后"
    end
    attribute :attendance_date, :date do
      allow_nil? false
      public? true
    end
    attribute :check_in_mode, :atom do
      constraints one_of: [:kiosk, :systray, :manual]
      public? true
      description "签到方式"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :employee, UniboExPoc.HR.Employee do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      description "签到"
      primary? true
      accept [:check_in, :attendance_date, :check_in_mode]
      argument :employee_id, :uuid, allow_nil?: false
      change manage_relationship(:employee_id, :employee, type: :append, on_lookup: :relate)
      # validation: custom_check
      # validation: custom_check
      change set_attribute(:id, expr(id))
    end
    update :check_out do
      description "签退，自动计算 worked_hours 和 overtime_hours"
      primary? true
      accept [:check_out]
      # skipped: validate compare :check_out (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
