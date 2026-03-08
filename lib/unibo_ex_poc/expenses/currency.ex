defmodule UniboV4.Expenses.Currency do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Expenses,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "币种占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "expenses_currencies"
    repo UniboV4.Repo
  end

  graphql do
    type :expenses_currency

    queries do
      get :get_expenses_currency, :read
      list :list_expenses_currencys, :read
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
