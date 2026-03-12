defmodule UniboExPoc.Purchasing.Product do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Purchasing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "产品占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "purchasing_products"
    repo UniboExPoc.Repo
  end

  graphql do
    type :purchasing_product

    queries do
      get :get_purchasing_product, :read
      list :list_purchasing_products, :read
      get :get_list_purchasing_product, :list
      list :list_list_purchasing_products, :list
      get :get_search_purchasing_product, :search
      list :list_search_purchasing_products, :search
      get :get_get_purchasing_product, :get
      list :list_get_purchasing_products, :get
      get :get_preview_purchasing_product, :preview
      list :list_preview_purchasing_products, :preview
      get :get_compute_purchasing_product, :compute
      list :list_compute_purchasing_products, :compute
      get :get_lookup_purchasing_product, :lookup
      list :list_lookup_purchasing_products, :lookup
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true
  end

  actions do
    defaults [:read, :update]
    read :list do
      description "列表查询"
    end
    read :search do
      description "条件检索"
    end
    read :get do
      description "详情查询"
    end
    read :preview do
      description "预览查询"
    end
    read :compute do
      description "计算查询"
    end
    read :lookup do
      description "快速检索"
    end
  end

end
