defmodule UniboV4.Gamification.ChallengeUserLink do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Gamification,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "gamification_challenge_user_links"
    repo UniboV4.Repo
  end

  graphql do
    type :gamification_challenge_user_link

    queries do
      get :get_gamification_challenge_user_link, :read
      list :list_gamification_challenge_user_links, :read
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :challenge, UniboV4.Gamification.Challenge do
      public? true
      allow_nil? false
    end
    belongs_to :user, UniboV4.Gamification.ResUser do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
  end

end
