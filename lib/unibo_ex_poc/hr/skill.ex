# Workflow: skill_write_flow — Skill 写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.HR.Skill do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "技能（配置实体）"
  end

  postgres do
    table "hr_skills"
    repo UniboExPoc.Repo
  end

  graphql do
    type :hr_skill

    queries do
      get :get_hr_skill, :read
      list :list_hr_skills, :read
    end

    mutations do
      create :create_hr_skill, :create
      update :update_hr_skill, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "技能名称"
    end
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :skill_type, UniboExPoc.HR.SkillType do
      public? true
    end
    has_many :employee_skills, UniboExPoc.HR.EmployeeSkill do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :skill_type_id, :description]
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :description]
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
