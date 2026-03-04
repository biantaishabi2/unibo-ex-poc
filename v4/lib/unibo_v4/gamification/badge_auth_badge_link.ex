defmodule UniboV4.Gamification.BadgeAuthBadgeLink do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Gamification,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "gamification_badge_auth_badge_links"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :badge, UniboV4.Gamification.Badge do
      public? true
      allow_nil? false
    end
    belongs_to :required_badge, UniboV4.Gamification.Badge do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
  end

end
