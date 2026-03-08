# Workflow: supplierinfo_lifecycle — 供应商报价记录管理
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> update
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Purchasing.ProductSupplierinfo do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Purchasing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource],
    authorizers: [Ash.Policy.Authorizer],
    notifiers: [UniboV4.Purchasing.ProductSupplierinfo.Notifier]

  resource do
    description "产品供应商报价记录（对齐 OFBiz SupplierProduct），由 PurchaseOrder 确认时自动写入"
  end

  postgres do
    table "purchasing_product_supplierinfos"
    repo UniboV4.Repo
  end

  graphql do
    type :purchasing_product_supplierinfo

    queries do
      get :get_purchasing_product_supplierinfo, :read
      list :list_purchasing_product_supplierinfos, :read
      get :get_list_purchasing_product_supplierinfo, :list
      list :list_list_purchasing_product_supplierinfos, :list
      get :get_search_purchasing_product_supplierinfo, :search
      list :list_search_purchasing_product_supplierinfos, :search
      get :get_get_purchasing_product_supplierinfo, :get
      list :list_get_purchasing_product_supplierinfos, :get
      get :get_preview_purchasing_product_supplierinfo, :preview
      list :list_preview_purchasing_product_supplierinfos, :preview
      get :get_compute_purchasing_product_supplierinfo, :compute
      list :list_compute_purchasing_product_supplierinfos, :compute
      get :get_lookup_purchasing_product_supplierinfo, :lookup
      list :list_lookup_purchasing_product_supplierinfos, :lookup
    end

    mutations do
      create :create_purchasing_product_supplierinfo, :create
      update :update_purchasing_product_supplierinfo, :update
      destroy :delete_purchasing_product_supplierinfo, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :partner_id, :uuid do
      allow_nil? false
      public? true
      description "供应商（对齐 OFBiz party_id，子联系人取 parent_id）"
    end
    attribute :product_id, :uuid do
      public? true
      description "产品（对齐 OFBiz product_id）"
    end
    attribute :available_from_date, :date do
      public? true
      description "供应起始日（对齐 OFBiz available_from_date）"
    end
    attribute :available_thru_date, :date do
      public? true
      description "供应截止日（对齐 OFBiz available_thru_date）"
    end
    attribute :minimum_order_quantity, :decimal do
      default 0
      public? true
      description "最小采购量（对齐 OFBiz minimum_order_quantity）"
    end
    attribute :standard_lead_time_days, :integer do
      default 1
      public? true
      description "标准交货提前期天数（对齐 OFBiz standard_lead_time_days）"
    end
    attribute :last_price, :decimal do
      allow_nil? false
      public? true
      description "最近报价（对齐 OFBiz last_price）"
    end
    attribute :shipping_price, :decimal do
      public? true
      description "运费（对齐 OFBiz shipping_price）"
    end
    attribute :currency_uom_id, :uuid do
      allow_nil? false
      public? true
      description "报价币种（对齐 OFBiz currency_uom_id）"
    end
    attribute :supplier_product_name, :string do
      public? true
      description "供应商产品名称（对齐 OFBiz supplier_product_name）"
    end
    attribute :supplier_product_id, :string do
      public? true
      description "供应商产品编号（对齐 OFBiz supplier_product_id）"
    end
    attribute :can_drop_ship, :boolean do
      default false
      public? true
      description "是否支持直发（对齐 OFBiz can_drop_ship）"
    end
    attribute :comments, :string do
      public? true
      description "备注（对齐 OFBiz comments）"
    end
    attribute :order_qty_increments, :decimal do
      public? true
      description "订单数量增量（对齐 OFBiz order_qty_increments）"
    end
    attribute :product_tmpl_id, :uuid do
      allow_nil? false
      public? true
      description "产品模板（业务扩展，Odoo 模板概念）"
    end
    attribute :discount, :decimal do
      default 0
      public? true
      description "折扣率%（业务扩展）"
    end
    attribute :sequence, :integer do
      default 1
      public? true
      description "排序序号（业务扩展）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :supplier, UniboV4.Purchasing.Supplier do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:partner_id, :product_tmpl_id, :product_id, :last_price, :currency_uom_id, :minimum_order_quantity, :standard_lead_time_days, :discount, :available_from_date, :available_thru_date, :sequence, :supplier_product_name, :supplier_product_id, :can_drop_ship, :shipping_price, :comments, :order_qty_increments]
      argument :supplier_id, :uuid, allow_nil?: false
      change manage_relationship(:supplier_id, :supplier, type: :append, on_lookup: :relate)
      validate present(:partner_id)
      validate present(:product_tmpl_id)
      change UniboV4.Purchasing.Changes.ProductSupplierinfo.ComputePartnerId
      change UniboV4.Purchasing.Changes.ProductSupplierinfo.ComputeLastPrice
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:last_price, :currency_uom_id, :minimum_order_quantity, :standard_lead_time_days, :discount, :available_from_date, :available_thru_date, :sequence, :supplier_product_name, :can_drop_ship, :shipping_price, :comments]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
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

  validations do
    validate compare(:last_price, greater_than_or_equal_to: 0)
    validate compare(:minimum_order_quantity, greater_than_or_equal_to: 0)
    validate compare(:standard_lead_time_days, greater_than_or_equal_to: 0)
  end

  identities do
    identity :unique_supplier_product, [:partner_id, :product_tmpl_id, :minimum_order_quantity]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

  policies do
    policy action_type(:create) do
      authorize_if always()
    end
  end

end
