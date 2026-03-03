defmodule UniboV4.Ecommerce.DeliveryCarrier do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Ecommerce,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "ecommerce_delivery_carriers"
    repo UniboV4.Repo
  end

  graphql do
    type :ecommerce_delivery_carrier

    queries do
      get :get_ecommerce_delivery_carrier, :read
      list :list_ecommerce_delivery_carriers, :read
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
