defmodule UniboExPoc.Delivery.Product do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Delivery,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "产品占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "delivery_products"
    repo UniboExPoc.Repo
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
