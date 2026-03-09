defmodule UniboExPoc.Rental.Product do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Rental,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "跨域产品占位实体"
  end

  postgres do
    table "rental_products"
    repo UniboExPoc.Repo
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
