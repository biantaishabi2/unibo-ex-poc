defmodule UniboV4.POS.Product do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.POS,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "产品占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "pos_products"
    repo UniboV4.Repo
  end

  graphql do
    type :pos_product

    queries do
      get :get_pos_product, :read
      list :list_pos_products, :read
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
