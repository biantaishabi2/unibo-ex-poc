defmodule UniboExPoc.Gamification.Party do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Gamification,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "跨域引用 Organization.Party（统一主体）"
  end

  postgres do
    table "gamification_parties"
    repo UniboExPoc.Repo
  end

  graphql do
    type :gamification_party

    queries do
      get :get_gamification_party, :read
      list :list_gamification_partys, :read
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
