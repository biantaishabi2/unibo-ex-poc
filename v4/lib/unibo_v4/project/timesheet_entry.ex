# Workflow: timesheet_entry_write_flow — 工时记录写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.Project.TimesheetEntry do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Project,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "project_timesheet_entries"
    repo UniboV4.Repo
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
    end
    attribute :hours, :decimal do
      allow_nil? false
      public? true
    end
    attribute :work_date, :date do
      allow_nil? false
      public? true
    end
    attribute :name, :string do
      default "/"
      public? true
    end
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :timesheet, UniboV4.Project.Timesheet do
      public? true
      allow_nil? false
    end
    belongs_to :task, UniboV4.Project.Task do
      public? true
    end
    belongs_to :project, UniboV4.Project.Project do
      public? true
      allow_nil? false
    end
    belongs_to :employee, UniboV4.Project.Employee do
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
      # TODO: 不支持的 action 内校验规则 custom
      validate present(:project_analytic_account_id)
      # message: "项目/任务必须关联有效分析账户"
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: 不支持的 change effect compute
      # TODO: 不支持的 change effect auto_resolve
      # TODO: 不支持的 change effect suggest_default
      # TODO: 不支持的 change effect compute
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :update do
      primary? true
      accept [:hours, :name, :description]
      argument :task_id, :uuid
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate owner_or_role :employee_user_id (incompatible with bulk update atomic path)
      # TODO: 不支持的 change effect compute
      # TODO: 不支持的表达式类型
      # TODO: 不支持的 change effect compute
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
  end

  validations do
    validate compare(:hours, greater_than: 0)
  end

end
