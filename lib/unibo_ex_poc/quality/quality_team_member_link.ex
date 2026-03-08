defmodule UniboV4.Quality.QualityTeamMemberLink do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Quality,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "质量团队-成员桥接占位实体"
  end

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
    belongs_to :member, UniboV4.Quality.Party do
      public? true
      allow_nil? false
      source_attribute :member_party_id
    end
  end

  actions do
    defaults [:read, :update]
  end

end
