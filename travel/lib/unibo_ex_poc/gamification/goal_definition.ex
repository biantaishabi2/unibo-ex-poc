# Workflow: goal_definition_lifecycle_flow — 目标定义创建、更新与删除流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   destroy --> [*]
# ```
defmodule UniboExPoc.Gamification.GoalDefinition do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Gamification,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "目标定义模板，支持4种计算模式（手动/计数/求和/Python脚本）"
  end

  postgres do
    table "gamification_goal_definitions"
    repo UniboExPoc.Repo
  end

  graphql do
    type :gamification_goal_definition

    queries do
      get :get_gamification_goal_definition, :read
      list :list_gamification_goal_definitions, :read
    end

    mutations do
      create :create_gamification_goal_definition, :create
      update :update_gamification_goal_definition, :update
      destroy :delete_gamification_goal_definition, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "目标定义名称"
    end
    attribute :description, :string do
      public? true
      description "目标描述"
    end
    attribute :monetary, :boolean do
      default false
      public? true
      description "是否为货币值"
    end
    attribute :suffix, :string do
      public? true
      description "单位后缀"
    end
    attribute :computation_mode, :atom do
      allow_nil? false
      constraints one_of: [:manually, :count, :sum, :python]
      default :manually
      public? true
      description "计算方式（手动/计数/求和/Python脚本）"
    end
    attribute :display_mode, :atom do
      constraints one_of: [:progress, :boolean]
      default :progress
      public? true
      description "展示方式（进度条/布尔达成）"
    end
    attribute :domain, :string do
      default "[]"
      public? true
      description "过滤域表达式"
    end
    attribute :batch_mode, :boolean do
      default false
      public? true
      description "是否批量评估"
    end
    attribute :batch_user_expression, :string do
      public? true
      description "批量模式下用户表达式"
    end
    attribute :compute_code, :string do
      public? true
      description "Python代码（computation_mode=python时使用）"
    end
    attribute :condition, :atom do
      constraints one_of: [:higher, :lower]
      default :higher
      public? true
      description "目标方向（越高越好/越低越好）"
    end
    attribute :res_id_field, :string do
      public? true
      description "用户profile上的res_id字段名"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  calculations do
    calculate :full_suffix, :string, expr(compute_full_suffix(monetary, suffix))
  end

  relationships do
    has_many :goals, UniboExPoc.Gamification.Goal do
      public? true
      destination_attribute :definition_id
    end
    has_many :challenge_lines, UniboExPoc.Gamification.ChallengeLine do
      public? true
      destination_attribute :definition_id
    end
    has_many :translations, UniboExPoc.Gamification.GoalDefinitionTranslation, public?: true
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :description, :monetary, :suffix, :computation_mode, :display_mode, :domain, :batch_mode, :batch_user_expression, :compute_code, :condition, :res_id_field]
      validate present(:name)
      validate present(:computation_mode)
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
      accept [:name, :description, :monetary, :suffix, :computation_mode, :display_mode, :domain, :batch_mode, :batch_user_expression, :compute_code, :condition, :res_id_field]
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

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:goals, :challenge_lines]
  end

end
