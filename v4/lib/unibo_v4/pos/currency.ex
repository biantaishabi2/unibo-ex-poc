defmodule UniboV4.POS.Currency do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.POS,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "pos_currencies"
    repo UniboV4.Repo
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
