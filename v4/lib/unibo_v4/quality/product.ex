defmodule UniboV4.Quality.Product do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Quality,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "quality_products"
    repo UniboV4.Repo
  end

  graphql do
    type :quality_product

    queries do
      get :get_quality_product, :read
      list :list_quality_products, :read
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
