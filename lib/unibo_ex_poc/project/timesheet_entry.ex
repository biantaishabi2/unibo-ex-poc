# Workflow: timesheet_entry_write_flow — 工时记录写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.Project.TimesheetEntry do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Project,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "工时记录"
  end

  postgres do
    table "project_timesheet_entries"
    repo UniboExPoc.Repo
  end

  graphql do
    type :project_timesheet_entry

    mutations do
      create :create_project_timesheet_entry, :create
      update :update_project_timesheet_entry, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :date, :date do
      allow_nil? false
      default &Date.utc_today/0
      public? true
      description "工时日期"
    end
    attribute :hours, :decimal do
      allow_nil? false
      public? true
      description "工时数量（小时或天）"
    end
    attribute :work_date, :date do
      allow_nil? false
      public? true
    end
    attribute :name, :string do
      default "/"
      public? true
      description "工时描述"
    end
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :timesheet, UniboExPoc.Project.Timesheet do
      public? true
      allow_nil? false
    end
    belongs_to :task, UniboExPoc.Project.Task do
      public? true
    end
    belongs_to :project, UniboExPoc.Project.Project do
      public? true
      allow_nil? false
    end
    belongs_to :employee, UniboExPoc.Project.Employee do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:date, :hours, :work_date, :name, :description]
      argument :task_id, :uuid
      argument :project_id, :uuid, allow_nil?: false
      argument :timesheet_id, :uuid, allow_nil?: false
      change manage_relationship(:timesheet_id, :timesheet, type: :append, on_lookup: :relate)
      change manage_relationship(:project_id, :project, type: :append, on_lookup: :relate)
      argument :employee_id, :uuid, allow_nil?: false
      change manage_relationship(:employee_id, :employee, type: :append, on_lookup: :relate)
      # validation: custom_check — 私人任务（无 project_id）禁止创建工时条目
      # validation: custom_check — 员工必须在所选公司中处于激活状态
      change UniboExPoc.Project.Changes.TimesheetEntry.ComputeAmount
      change UniboExPoc.Project.Changes.TimesheetEntry.CreateCall2
      change UniboExPoc.Project.Changes.TimesheetEntry.ComputeProjectId
      change UniboExPoc.Project.Changes.TimesheetEntry.CreateCall5
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:hours, :name, :description, :task_id]
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate owner_or_role :employee_user_id (incompatible with bulk update atomic path)
      change UniboExPoc.Project.Changes.TimesheetEntry.ComputeAmount
      change UniboExPoc.Project.Changes.TimesheetEntry.ComputeProjectId
      change UniboExPoc.Project.Changes.TimesheetEntry.UpdateCall5
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  validations do
    validate compare(:hours, greater_than: 0)
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
