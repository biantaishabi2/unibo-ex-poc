defmodule UniboV4.Sales.SalesOrderItemTaxRel do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Sales,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "销售订单行与税率的关联占位实体"
  end

  postgres do
    table "sales_order_item_tax_rels"
    repo UniboV4.Repo
  end

  graphql do
    type :sales_sales_order_item_tax_rel

    queries do
      get :get_sales_sales_order_item_tax_rel, :read
      list :list_sales_sales_order_item_tax_rels, :read
      get :get_list_sales_sales_order_item_tax_rel, :list
      list :list_list_sales_sales_order_item_tax_rels, :list
      get :get_search_sales_sales_order_item_tax_rel, :search
      list :list_search_sales_sales_order_item_tax_rels, :search
      get :get_get_sales_sales_order_item_tax_rel, :get
      list :list_get_sales_sales_order_item_tax_rels, :get
      get :get_preview_sales_sales_order_item_tax_rel, :preview
      list :list_preview_sales_sales_order_item_tax_rels, :preview
      get :get_compute_sales_sales_order_item_tax_rel, :compute
      list :list_compute_sales_sales_order_item_tax_rels, :compute
      get :get_lookup_sales_sales_order_item_tax_rel, :lookup
      list :list_lookup_sales_sales_order_item_tax_rels, :lookup
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :order_item, UniboV4.Sales.SalesOrderItem do
      public? true
      allow_nil? false
      source_attribute :sales_order_item_id
    end
    belongs_to :tax, UniboV4.Sales.Tax do
      public? true
      allow_nil? false
    end
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
