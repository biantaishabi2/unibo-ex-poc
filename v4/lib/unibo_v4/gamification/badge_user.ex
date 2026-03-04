# Workflow: badge_user_grant_revoke_flow — 勋章授予与撤销流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   destroy --> [*]
# ```
defmodule UniboV4.Gamification.BadgeUser do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Gamification,
    data_layer: AshPostgres.DataLayer,
    notifiers: [UniboV4.Gamification.BadgeUser.Notifier]

  postgres do
    table "gamification_badge_users"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :comment, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :user, UniboV4.Gamification.ResUser do
      public? true
      allow_nil? false
    end
    belongs_to :sender, UniboV4.Gamification.ResUser do
      public? true
    end
    belongs_to :badge, UniboV4.Gamification.Badge do
      public? true
      allow_nil? false
    end
    belongs_to :challenge, UniboV4.Gamification.Challenge do
      public? true
    end
  end

  actions do
    defaults [:read, :destroy]
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
