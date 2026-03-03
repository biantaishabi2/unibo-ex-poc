defmodule UniboV4.Rental.Product do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Rental,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "rental_products"
    repo UniboV4.Repo
  end

  graphql do
    type :rental_product

    queries do
      get :get_rental_product, :read
      list :list_rental_products, :read
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
