defmodule UniboV4.POS.PosPaymentMethod do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.POS,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "pos_payment_methods"
    repo UniboV4.Repo
  end

  graphql do
    type :pos_pos_payment_method

    queries do
      get :get_pos_pos_payment_method, :read
      list :list_pos_pos_payment_methods, :read
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
