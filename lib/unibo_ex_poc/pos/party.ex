defmodule UniboV4.POS.Party do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.POS,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "跨域引用 Organization.Party（统一主体）"
  end

  postgres do
    table "pos_parties"
    repo UniboV4.Repo
  end

  graphql do
    type :pos_party

    queries do
      get :get_pos_party, :read
      list :list_pos_partys, :read
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
