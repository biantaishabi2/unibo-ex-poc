defmodule UniboV4.Analytic.Currency do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Analytic,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "币种占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "analytic_currencies"
    repo UniboV4.Repo
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
