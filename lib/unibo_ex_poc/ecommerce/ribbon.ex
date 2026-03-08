defmodule UniboV4.Ecommerce.Ribbon do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ecommerce,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "角标占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "ecommerce_ribbons"
    repo UniboV4.Repo
  end

  graphql do
    type :ecommerce_ribbon

    queries do
      get :get_ecommerce_ribbon, :read
      list :list_ecommerce_ribbons, :read
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
