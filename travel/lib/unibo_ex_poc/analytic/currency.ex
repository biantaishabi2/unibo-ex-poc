defmodule UniboExPoc.Analytic.Currency do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Analytic,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "币种占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "analytic_currencies"
    repo UniboExPoc.Repo
  end

  graphql do
    type :analytic_currency

    queries do
      get :get_analytic_currency, :read
      list :list_analytic_currencys, :read
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
