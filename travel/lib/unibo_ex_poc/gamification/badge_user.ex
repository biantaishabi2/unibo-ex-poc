# Workflow: badge_user_grant_revoke_flow — 勋章授予与撤销流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   destroy --> [*]
# ```
defmodule UniboExPoc.Gamification.BadgeUser do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Gamification,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource],
    notifiers: [UniboExPoc.Gamification.BadgeUser.Notifier]

  resource do
    description "用户获得的勋章实例，记录授予者、评语和关联挑战"
  end

  postgres do
    table "gamification_badge_users"
    repo UniboExPoc.Repo
  end

  graphql do
    type :gamification_badge_user

    queries do
      get :get_gamification_badge_user, :read
      list :list_gamification_badge_users, :read
    end

    mutations do
      create :create_gamification_badge_user, :create
      destroy :delete_gamification_badge_user, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :comment, :string do
      public? true
      description "授予评语"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :user, UniboExPoc.Gamification.Party do
      public? true
      allow_nil? false
      source_attribute :user_party_id
    end
    belongs_to :sender, UniboExPoc.Gamification.Party do
      public? true
      source_attribute :sender_party_id
    end
    belongs_to :badge, UniboExPoc.Gamification.Badge do
      public? true
      allow_nil? false
    end
    belongs_to :challenge, UniboExPoc.Gamification.Challenge do
      public? true
    end
  end

  actions do
    defaults [:read, :destroy, :update]
    create :create do
      primary? true
      accept [:comment]
      argument :user_id, :uuid, allow_nil?: false
      argument :sender_id, :uuid
      argument :badge_id, :uuid, allow_nil?: false
      argument :challenge_id, :uuid
      change manage_relationship(:user_id, :user, type: :append, on_lookup: :relate)
      change manage_relationship(:badge_id, :badge, type: :append, on_lookup: :relate)
      validate present(:user_id)
      validate present(:badge_id)
      change set_attribute(:id, expr(id))
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
