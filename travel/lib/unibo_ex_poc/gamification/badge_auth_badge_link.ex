defmodule UniboExPoc.Gamification.BadgeAuthBadgeLink do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Gamification,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "勋章-前置勋章桥接占位实体"
  end

  postgres do
    table "gamification_badge_auth_badge_links"
    repo UniboExPoc.Repo
  end

  graphql do
    type :gamification_badge_auth_badge_link

    queries do
      get :get_gamification_badge_auth_badge_link, :read
      list :list_gamification_badge_auth_badge_links, :read
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :badge, UniboExPoc.Gamification.Badge do
      public? true
      allow_nil? false
    end
    belongs_to :required_badge, UniboExPoc.Gamification.Badge do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
  end

end
