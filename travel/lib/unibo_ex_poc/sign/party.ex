defmodule UniboExPoc.Sign.Party do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Sign,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "跨域引用 Organization.Party（统一主体）"
  end

  postgres do
    table "sign_parties"
    repo UniboExPoc.Repo
  end

  graphql do
    type :sign_party

    queries do
      get :get_sign_party, :read
      list :list_sign_partys, :read
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
