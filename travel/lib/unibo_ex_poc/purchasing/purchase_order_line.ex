# Workflow: order_line_editing — 采购订单行编辑流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> [*]
# ```
defmodule UniboExPoc.Purchasing.PurchaseOrderLine do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Purchasing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "采购订单明细行（对齐 OFBiz OrderItem）"
  end

  postgres do
    table "purchasing_purchase_order_lines"
    repo UniboExPoc.Repo
  end

  graphql do
    type :purchasing_purchase_order_line

    queries do
      get :get_purchasing_purchase_order_line, :read
      list :list_purchasing_purchase_order_lines, :read
      get :get_list_purchasing_purchase_order_line, :list
      list :list_list_purchasing_purchase_order_lines, :list
      get :get_search_purchasing_purchase_order_line, :search
      list :list_search_purchasing_purchase_order_lines, :search
      get :get_get_purchasing_purchase_order_line, :get
      list :list_get_purchasing_purchase_order_lines, :get
      get :get_preview_purchasing_purchase_order_line, :preview
      list :list_preview_purchasing_purchase_order_lines, :preview
      get :get_compute_purchasing_purchase_order_line, :compute
      list :list_compute_purchasing_purchase_order_lines, :compute
      get :get_lookup_purchasing_purchase_order_line, :lookup
      list :list_lookup_purchasing_purchase_order_lines, :lookup
    end

    mutations do
      create :create_purchasing_purchase_order_line, :create
      update :update_purchasing_purchase_order_line, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :order_item_type_id, :string do
      public? true
      description "行类型（对齐 OFBiz order_item_type_id，替代 Odoo display_type）"
    end
    attribute :seq_id, :integer do
      public? true
      description "行序号（对齐 OFBiz order_item_seq_id）"
    end
    attribute :item_description, :string do
      allow_nil? false
      public? true
      description "行描述（对齐 OFBiz item_description）"
    end
    attribute :product_id, :uuid do
      public? true
      description "产品（对齐 OFBiz product_id，非 display 行必填）"
    end
    attribute :quantity, :decimal do
      allow_nil? false
      public? true
      description "数量（对齐 OFBiz quantity）"
    end
    attribute :cancel_quantity, :decimal do
      public? true
      description "取消数量（对齐 OFBiz cancel_quantity）"
    end
    attribute :unit_price, :decimal do
      allow_nil? false
      public? true
      description "成交单价（对齐 OFBiz unit_price）"
    end
    attribute :unit_list_price, :decimal do
      public? true
      description "目录/标牌价（对齐 OFBiz unit_list_price）"
    end
    attribute :discount_rate, :decimal do
      default 0
      public? true
      description "折扣率（对齐 OFBiz discount_rate）"
    end
    attribute :status_id, :string do
      public? true
      description "行状态（对齐 OFBiz status_id）"
    end
    attribute :estimated_delivery_date, :utc_datetime do
      public? true
      description "预计交货日（对齐 OFBiz estimated_delivery_date）"
    end
    attribute :comments, :string do
      public? true
      description "备注（对齐 OFBiz comments）"
    end
    attribute :supplier_product_id, :string do
      public? true
      description "供应商产品编号（对齐 OFBiz supplier_product_id）"
    end
    attribute :corresponding_po_id, :string do
      public? true
      description "对应采购单（对齐 OFBiz corresponding_po_id）"
    end
    attribute :is_promo, :boolean do
      default false
      public? true
      description "是否促销项（对齐 OFBiz is_promo）"
    end
    attribute :product_uom_id, :uuid do
      public? true
      description "产品单位（业务扩展，OFBiz 在 Product 上）"
    end
    attribute :product_packaging_id, :uuid do
      public? true
      description "包装（业务扩展）"
    end
    attribute :product_packaging_qty, :decimal do
      public? true
      description "包装数量（业务扩展）"
    end
    attribute :qty_received_method, :atom do
      constraints one_of: [:manual, :stock_move]
      public? true
      description "收货计算方式：manual（消耗品/服务）或 stock_move"
    end
    attribute :qty_received_manual, :decimal do
      public? true
      description "手动填写的收货数量"
    end
    attribute :taxes_id, :map do
      public? true
      description "税种（业务扩展，OFBiz 用 OrderAdjustment 外置）"
    end
    attribute :analytic_distribution, :map do
      public? true
      description "分析账户分配 JSON（业务扩展）"
    end
    attribute :company_id, :uuid do
      public? true
      description "公司（继承自订单）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :price_unit_discounted, :decimal, expr((unit_price * (1 - (discount_rate / 100))))
    calculate :price_subtotal, :decimal, expr(price_unit_discounted)
    calculate :price_total, :decimal, expr(price_subtotal)
    calculate :price_tax, :decimal, expr(price_total)
    calculate :qty_received, :decimal, expr(qty_received_manual)
    calculate :qty_invoiced, :decimal, expr(qty_received)
    calculate :qty_to_invoice, :decimal, {UniboExPoc.Purchasing.Calculations.PurchaseOrderLine.QtyToInvoice, []}
  end

  relationships do
    belongs_to :order, UniboExPoc.Purchasing.PurchaseOrder do
      public? true
      allow_nil? false
    end
    has_many :invoice_lines, UniboExPoc.Purchasing.AccountMoveLine do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:item_description, :product_id, :product_uom_id, :quantity, :product_packaging_id, :product_packaging_qty, :unit_price, :discount_rate, :estimated_delivery_date, :taxes_id, :analytic_distribution, :order_item_type_id, :seq_id, :qty_received_manual, :supplier_product_id, :comments, :status_id]
      argument :order_id, :uuid, allow_nil?: false
      change manage_relationship(:order_id, :order, type: :append, on_lookup: :relate)
      # validation: accountable_required_fields — 非 display 行必须填写产品、单位和计划交货日期
      # validation: non_accountable_null_fields — 段落/备注行的产品、单位、价格、数量、日期必须为空
      # validation: product_purchase_warn_block — 该产品已被设置为采购阻止，无法选择
      change UniboExPoc.Purchasing.Changes.PurchaseOrderLine.ComputeUnitPrice
      change UniboExPoc.Purchasing.Changes.PurchaseOrderLine.ComputeDiscountRate
      change UniboExPoc.Purchasing.Changes.PurchaseOrderLine.ComputeEstimatedDeliveryDate
      change UniboExPoc.Purchasing.Changes.PurchaseOrderLine.ComputeAnalyticDistribution
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:quantity, :unit_price, :discount_rate, :estimated_delivery_date, :taxes_id, :analytic_distribution, :qty_received_manual, :comments, :status_id]
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change UniboExPoc.Purchasing.Changes.PurchaseOrderLine.ComputeUnitPrice
      change UniboExPoc.Purchasing.Changes.PurchaseOrderLine.ComputeDiscountRate
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
    validate compare(:quantity, greater_than: 0)
    validate compare(:unit_price, greater_than_or_equal_to: 0)
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
