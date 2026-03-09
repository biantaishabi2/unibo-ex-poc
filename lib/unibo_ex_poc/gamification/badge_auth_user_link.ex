defmodule UniboExPoc.Gamification.BadgeAuthUserLink do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Gamification,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "勋章-授权用户桥接占位实体"
  end

  postgres do
    table "gamification_badge_auth_user_links"
    repo UniboExPoc.Repo
  end

  graphql do
    type :gamification_badge_auth_user_link

    queries do
      get :get_gamification_badge_auth_user_link, :read
      list :list_gamification_badge_auth_user_links, :read
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
    belongs_to :user, UniboExPoc.Gamification.Party do
      public? true
      allow_nil? false
      source_attribute :user_party_id
    end
  end

  actions do
    defaults [:read, :update]
  end

end
