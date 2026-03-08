defmodule UniboExPoc.Subscriptions.Product do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Subscriptions,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "产品占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "subscriptions_products"
    repo UniboExPoc.Repo
  end

  graphql do
    type :subscriptions_product

    queries do
      get :get_subscriptions_product, :read
      list :list_subscriptions_products, :read
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
