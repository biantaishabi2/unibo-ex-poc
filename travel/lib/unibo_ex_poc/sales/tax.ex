defmodule UniboExPoc.Sales.Tax do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Sales,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "税率占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "sales_taxes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :sales_tax

    queries do
      get :get_sales_tax, :read
      list :list_sales_taxs, :read
      get :get_list_sales_tax, :list
      list :list_list_sales_taxs, :list
      get :get_search_sales_tax, :search
      list :list_search_sales_taxs, :search
      get :get_get_sales_tax, :get
      list :list_get_sales_taxs, :get
      get :get_preview_sales_tax, :preview
      list :list_preview_sales_taxs, :preview
      get :get_compute_sales_tax, :compute
      list :list_compute_sales_taxs, :compute
      get :get_lookup_sales_tax, :lookup
      list :list_lookup_sales_taxs, :lookup
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
