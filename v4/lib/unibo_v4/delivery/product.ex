defmodule UniboV4.Delivery.Product do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Delivery,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "delivery_products"
    repo UniboV4.Repo
  end

  graphql do
    type :delivery_product

    queries do
      get :get_delivery_product, :read
      list :list_delivery_products, :read
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
