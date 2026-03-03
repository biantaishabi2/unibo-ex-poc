defmodule UniboV4.Quality.QualityTeamMemberLink do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Quality,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "quality_team_member_links"
    repo UniboV4.Repo
  end

  graphql do
    type :quality_quality_team_member_link

    queries do
      get :get_quality_quality_team_member_link, :read
      list :list_quality_quality_team_member_links, :read
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :quality_team, UniboV4.Quality.QualityTeam do
      public? true
      allow_nil? false
    end
    belongs_to :user, UniboV4.Quality.User do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
  end

end
