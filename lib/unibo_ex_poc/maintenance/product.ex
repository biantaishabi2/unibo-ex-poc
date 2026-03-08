defmodule UniboV4.Maintenance.Product do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "产品占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "maintenance_products"
    repo UniboV4.Repo
  end

  graphql do
    type :maintenance_product

    queries do
      get :get_maintenance_product, :read
      list :list_maintenance_products, :read
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
