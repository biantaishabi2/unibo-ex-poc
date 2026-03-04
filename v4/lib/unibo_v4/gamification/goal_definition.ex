# Workflow: goal_definition_lifecycle_flow — 目标定义创建、更新与删除流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   destroy --> [*]
# ```
defmodule UniboV4.Gamification.GoalDefinition do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Gamification,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "gamification_goal_definitions"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :description, :string, public?: true
    attribute :monetary, :boolean do
      default false
      public? true
    end
    attribute :suffix, :string, public?: true
    attribute :computation_mode, :atom do
      allow_nil? false
      constraints one_of: [:manually, :count, :sum, :python]
      default :manually
      public? true
    end
    attribute :display_mode, :atom do
      constraints one_of: [:progress, :boolean]
      default :progress
      public? true
    end
    attribute :domain, :string do
      default "[]"
      public? true
    end
    attribute :batch_mode, :boolean do
      default false
      public? true
    end
    attribute :batch_user_expression, :string, public?: true
    attribute :compute_code, :string, public?: true
    attribute :condition, :atom do
      constraints one_of: [:higher, :lower]
      default :higher
      public? true
    end
    attribute :res_id_field, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :full_suffix
  end

  relationships do
    has_many :goals, UniboV4.Gamification.Goal do
      public? true
      destination_attribute :definition_id
    end
    has_many :challenge_lines, UniboV4.Gamification.ChallengeLine do
      public? true
      destination_attribute :definition_id
    end
    has_many :translations, UniboV4.Gamification.GoalDefinitionTranslation, public?: true
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

end
