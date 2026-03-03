# Workflow: employee_skill_log_write_flow — EmployeeSkillLog 写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   read --> [*]
# ```
defmodule UniboV4.HR.EmployeeSkillLog do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "hr_employee_skill_logs"
    repo UniboV4.Repo
  end

  graphql do
    type :hr_employee_skill_log

    queries do
      get :get_hr_employee_skill_log, :read
      list :list_hr_employee_skill_logs, :read
    end

    mutations do
      create :create_hr_employee_skill_log, :create
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :date, :date do
      allow_nil? false
      default &Date.utc_today/0
      public? true
    end
    attribute :level_progress, :integer, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :employee, UniboV4.HR.Employee do
      public? true
      allow_nil? false
    end
    belongs_to :department, UniboV4.HR.Department do
      public? true
    end
    belongs_to :skill, UniboV4.HR.Skill do
      public? true
      allow_nil? false
    end
    belongs_to :skill_level, UniboV4.HR.SkillLevel do
      public? true
      allow_nil? false
    end
    belongs_to :skill_type, UniboV4.HR.SkillType do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
    create :create do
      primary? true
      accept [:date, :level_progress]
      argument :employee_id, :uuid, allow_nil?: false
      argument :skill_id, :uuid, allow_nil?: false
      argument :skill_level_id, :uuid, allow_nil?: false
      argument :skill_type_id, :uuid, allow_nil?: false
      argument :department_id, :uuid
      change manage_relationship(:employee_id, :employee, type: :append, on_lookup: :relate)
      change manage_relationship(:skill_id, :skill, type: :append, on_lookup: :relate)
      change manage_relationship(:skill_level_id, :skill_level, type: :append, on_lookup: :relate)
      change manage_relationship(:skill_type_id, :skill_type, type: :append, on_lookup: :relate)
      validate present(:date)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
  end

end
