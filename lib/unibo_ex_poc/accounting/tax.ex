defmodule UniboExPoc.Accounting.Tax do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "税率占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "accounting_taxes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_tax

    queries do
      get :get_accounting_tax, :read
      list :list_accounting_taxs, :read
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
