# Workflow: employee_skill_write_flow — EmployeeSkill 写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.HR.EmployeeSkill do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "hr_employee_skills"
    repo UniboV4.Repo
  end

  graphql do
    type :hr_employee_skill

    queries do
      get :get_hr_employee_skill, :read
      list :list_hr_employee_skills, :read
    end

    mutations do
      create :create_hr_employee_skill, :create
      update :update_hr_employee_skill, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :employee_id, :uuid do
      allow_nil? false
      public? true
    end
    attribute :skill_id, :uuid do
      allow_nil? false
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :employee, UniboV4.HR.Employee do
      public? true
      allow_nil? false
    end
    belongs_to :skill, UniboV4.HR.Skill do
      public? true
      allow_nil? false
    end
    belongs_to :skill_level, UniboV4.HR.SkillLevel do
      public? true
    end
    belongs_to :skill_type, UniboV4.HR.SkillType do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept []
      argument :employee_id, :uuid, allow_nil?: false
      argument :skill_id, :uuid, allow_nil?: false
      argument :skill_level_id, :uuid
      argument :skill_type_id, :uuid
      change manage_relationship(:employee_id, :employee, type: :append, on_lookup: :relate)
      change manage_relationship(:skill_id, :skill, type: :append, on_lookup: :relate)
      # TODO: 不支持的 action 内校验规则 custom
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
      accept []
      argument :skill_level_id, :uuid
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

  identities do
    identity :unique_employee_skill, [:employee_id, :skill_id]
  end

end
