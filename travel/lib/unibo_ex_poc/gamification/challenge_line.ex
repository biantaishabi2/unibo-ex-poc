# Workflow: challenge_line_lifecycle_flow — 挑战目标行创建、更新与删除流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   destroy --> [*]
# ```
defmodule UniboExPoc.Gamification.ChallengeLine do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Gamification,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "挑战与目标定义的关联行，指定每条目标的目标值和排序"
  end

  postgres do
    table "gamification_challenge_lines"
    repo UniboExPoc.Repo
  end

  graphql do
    type :gamification_challenge_line

    queries do
      get :get_gamification_challenge_line, :read
      list :list_gamification_challenge_lines, :read
    end

    mutations do
      create :create_gamification_challenge_line, :create
      update :update_gamification_challenge_line, :update
      destroy :delete_gamification_challenge_line, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :sequence, :integer do
      default 1
      public? true
      description "排序序号"
    end
    attribute :target_goal, :float do
      allow_nil? false
      public? true
      description "该行的目标值"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :challenge, UniboExPoc.Gamification.Challenge do
      public? true
      allow_nil? false
    end
    belongs_to :definition, UniboExPoc.Gamification.GoalDefinition do
      public? true
      allow_nil? false
    end
    has_many :goals, UniboExPoc.Gamification.Goal do
      public? true
      destination_attribute :line_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:sequence, :target_goal]
      argument :challenge_id, :uuid, allow_nil?: false
      argument :definition_id, :uuid, allow_nil?: false
      change manage_relationship(:challenge_id, :challenge, type: :append, on_lookup: :relate)
      change manage_relationship(:definition_id, :definition, type: :append, on_lookup: :relate)
      validate present(:target_goal)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:sequence, :target_goal]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:goals]
  end

end
