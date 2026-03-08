defmodule UniboV4.Accounting.Party do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "跨域引用 Organization.Party（统一主体）"
  end

  postgres do
    table "accounting_parties"
    repo UniboV4.Repo
  end

  graphql do
    type :accounting_party

    queries do
      get :get_accounting_party, :read
      list :list_accounting_partys, :read
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
