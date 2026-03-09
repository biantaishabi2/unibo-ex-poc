defmodule UniboExPoc.POS.Currency do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.POS,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "币种占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "pos_currencies"
    repo UniboExPoc.Repo
  end

  graphql do
    type :pos_currency

    queries do
      get :get_pos_currency, :read
      list :list_pos_currencys, :read
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
