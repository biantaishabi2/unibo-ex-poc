# Workflow: skill_level_write_flow — SkillLevel 写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.HR.SkillLevel do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "技能等级，属于 SkillType（不同分类有不同等级体系，如\"初级/中级/高级\"）"
  end

  postgres do
    table "hr_skill_levels"
    repo UniboV4.Repo
  end

  graphql do
    type :hr_skill_level

    queries do
      get :get_hr_skill_level, :read
      list :list_hr_skill_levels, :read
    end

    mutations do
      create :create_hr_skill_level, :create
      update :update_hr_skill_level, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "等级名称，如\"初级\"、\"中级\"、\"高级\""
    end
    attribute :level_progress, :integer do
      public? true
      description "等级进度百分比（0-100）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :skill_type, UniboV4.HR.SkillType do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :level_progress]
      argument :skill_type_id, :uuid, allow_nil?: false
      change manage_relationship(:skill_type_id, :skill_type, type: :append, on_lookup: :relate)
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :level_progress]
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
