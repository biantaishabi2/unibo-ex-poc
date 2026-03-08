defmodule UniboV4.Helpdesk.Product do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Helpdesk,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "产品占位实体，供 FsmMaterialLine 引用（跨域最小字段）"
  end

  postgres do
    table "helpdesk_products"
    repo UniboV4.Repo
  end

  graphql do
    type :helpdesk_product

    queries do
      get :get_helpdesk_product, :read
      list :list_helpdesk_products, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      public? true
      description "产品名称"
    end
  end

  actions do
    defaults [:read, :update]
  end

end
