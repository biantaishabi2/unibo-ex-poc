defmodule UniboV4.Survey.Party do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Survey,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "跨域引用 Organization.Party（统一主体）"
  end

  postgres do
    table "survey_parties"
    repo UniboV4.Repo
  end

  graphql do
    type :survey_party

    queries do
      get :get_survey_party, :read
      list :list_survey_partys, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true
  end

  actions do
    defaults [:read, :update]
  end

end
