# Workflow: challenge_line_lifecycle_flow — 挑战目标行创建、更新与删除流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   destroy --> [*]
# ```
defmodule UniboV4.Gamification.ChallengeLine do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Gamification,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "gamification_challenge_lines"
    repo UniboV4.Repo
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
    end
    attribute :target_goal, :float do
      allow_nil? false
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :challenge, UniboV4.Gamification.Challenge do
      public? true
      allow_nil? false
    end
    belongs_to :definition, UniboV4.Gamification.GoalDefinition do
      public? true
      allow_nil? false
    end
    has_many :goals, UniboV4.Gamification.Goal do
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
      accept [:sequence, :target_goal]
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
