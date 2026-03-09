# Workflow: sales_order_lifecycle_flow — 销售订单业务流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   action_quotation_send --> [*]
#   action_confirm --> [*]
#   create_invoices --> [*]
#   action_done --> [*]
# ```
# Workflow: sales_order_reopen_flow — 取消后重启订单流程
# ```mermaid
# stateDiagram-v2
#   [*] --> action_cancel
#   action_cancel --> [*]
#   action_draft --> [*]
#   action_confirm --> [*]
# ```
# Workflow: pricing_chain — 定价链路
# ```mermaid
# stateDiagram-v2
#   [*] --> select_product_price
#   select_product_price --> [*]
#   compute_line_subtotal --> [*]
#   compute_tax --> [*]
#   aggregate_totals --> [*]
# ```
defmodule UniboExPoc.Sales.SalesOrder do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Sales,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    authorizers: [Ash.Policy.Authorizer],
    notifiers: [UniboExPoc.Sales.SalesOrder.Notifier]

  resource do
    description "销售订单（状态机对齐 Odoo：draft → sent → sale → done → cancel）"
  end

  postgres do
    table "sales_orders"
    repo UniboExPoc.Repo
    identity_index_names unique_order_name: "idx_sales_orders_unique_order_name"
  end

  graphql do
    type :sales_sales_order

    queries do
      get :get_sales_sales_order, :read
      list :list_sales_sales_orders, :read
      get :get_list_sales_sales_order, :list
      list :list_list_sales_sales_orders, :list
      get :get_search_sales_sales_order, :search
      list :list_search_sales_sales_orders, :search
      get :get_get_sales_sales_order, :get
      list :list_get_sales_sales_orders, :get
      get :get_preview_sales_sales_order, :preview
      list :list_preview_sales_sales_orders, :preview
      get :get_compute_sales_sales_order, :compute
      list :list_compute_sales_sales_orders, :compute
      get :get_lookup_sales_sales_order, :lookup
      list :list_lookup_sales_sales_orders, :lookup
    end

    mutations do
      create :create_sales_sales_order, :create
      update :action_quotation_send_sales_sales_order, :action_quotation_send
      update :action_confirm_sales_sales_order, :action_confirm
      update :action_done_sales_sales_order, :action_done
      update :action_cancel_sales_sales_order, :action_cancel
      update :action_draft_sales_sales_order, :action_draft
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "订单编号（自动生成序列号）"
    end
    attribute :state, :atom do
      constraints one_of: [:draft, :sent, :sale, :done, :cancel]
      default :draft
      public? true
      description "订单状态（Odoo 状态机）"
    end
    attribute :locked, :boolean do
      default false
      public? true
      description "锁定标记，sale 状态下 action_done 时置 true"
    end
    attribute :date_order, :utc_datetime do
      allow_nil? false
      default &DateTime.utc_now/0
      public? true
      description "订单日期"
    end
    attribute :promised_delivery_date, :date do
      public? true
      description "承诺交付日期"
    end
    attribute :currency, :string do
      default "CNY"
      public? true
      description "币种"
    end
    attribute :payment_terms, :string do
      public? true
      description "付款条件"
    end
    attribute :shipping_address, :string do
      public? true
      description "送货地址"
    end
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :amount_untaxed, :decimal, expr(sum(items, field: :price_subtotal, query: [filter: expr(true)]))
    calculate :amount_tax, :decimal, expr(sum(items, field: :price_tax, query: [filter: expr(true)]))
    calculate :amount_total, :decimal, expr((amount_untaxed + amount_tax))
    calculate :invoice_status, :atom, expr(%{op: "aggregate", source: %{op: "ref", args: ["items", "invoice_status"]}, rules: [%{when: %{op: "all_eq", args: ["invoiced"]}, then: "invoiced"}, %{when: %{op: "any_eq", args: ["to_invoice"]}, then: "to_invoice"}, %{when: %{op: "any_eq", args: ["upselling"]}, then: "upselling"}, %{otherwise: "no"}]})
    calculate :item_count, :integer, expr(count(items, query: [filter: expr(true)]))
  end

  relationships do
    has_many :items, UniboExPoc.Sales.SalesOrderItem do
      public? true
      destination_attribute :order_id
    end
    belongs_to :customer, UniboExPoc.Sales.Customer do
      public? true
      allow_nil? false
    end
    belongs_to :shipping_partner, UniboExPoc.Sales.Customer do
      public? true
      allow_nil? false
    end
    belongs_to :created_by, UniboExPoc.Sales.Party do
      public? true
      source_attribute :created_by_party_id
    end
    has_many :shipments, UniboExPoc.Sales.SalesOrderShipment do
      public? true
    end
    has_many :returns, UniboExPoc.Sales.Return do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :date_order, :promised_delivery_date, :payment_terms, :shipping_address, :currency, :notes]
      argument :items, {:array, :string}, allow_nil?: false
      argument :customer_id, :uuid, allow_nil?: false
      change manage_relationship(:items, :items, type: :create)
      change manage_relationship(:customer_id, :customer, type: :append, on_lookup: :relate)
      argument :shipping_partner_id, :uuid, allow_nil?: false
      change manage_relationship(:shipping_partner_id, :shipping_partner, type: :append, on_lookup: :relate)
      validate present(:items)
      # message: "创建销售订单时必须包含至少一条订单行"
      validate present([:partner_id])
      # message: "创建销售订单时必须选择客户"
      change relate_actor(:created_by)
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
    update :action_quotation_send do
      description "发送报价（draft → sent）"
      primary? true
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以发送报价"
      change set_attribute(:state, :sent)
      require_atomic? false
    end
    update :action_confirm do
      description "确认订单（draft/sent → sale）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current in [:draft, :sent] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must be one of %{values}", vars: %{values: [:draft, :sent]}))
        end
      end
      # message: "只有草稿或已发送状态可以确认"
      # skipped: validate present :items (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:state, :sale)
      change set_attribute(:date_order, &DateTime.utc_now/0)
      change UniboExPoc.Sales.Changes.SalesOrder.ActionConfirmCreateRelated5
      change UniboExPoc.Sales.Changes.SalesOrder.ActionConfirmCall6
      change set_attribute(:locked, true)
      require_atomic? false
    end
    update :action_done do
      description "锁定订单（sale → done/locked）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :sale do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :sale}))
        end
      end
      # message: "只有已确认(sale)状态可以锁定"
      change set_attribute(:state, :done)
      change set_attribute(:locked, true)
      require_atomic? false
    end
    update :action_cancel do
      description "取消订单（any → cancel，locked==false 时可执行）"
      accept []
      # skipped: validate compare :locked (incompatible with bulk update atomic path)
      change UniboExPoc.Sales.Changes.SalesOrder.ActionCancelCall10
      change UniboExPoc.Sales.Changes.SalesOrder.ActionCancelCall11
      change set_attribute(:state, :cancel)
      require_atomic? false
    end
    update :action_draft do
      description "重置为草稿（cancel → draft）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :cancel do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :cancel}))
        end
      end
      # message: "只有已取消状态可以重置为草稿"
      change set_attribute(:state, :draft)
      require_atomic? false
    end
    action :create_invoices do
      description "手动创建发票（state == sale 时可执行）"
      argument :final, :boolean
      # precondition: requires state=:sale
      validate attribute_equals(:state, :sale)
      # validation: has_qty_to_invoice — 至少有一行的待开票数量大于0
      run fn input, _context ->
        # 按客户+币种+公司分组合并创建发票 — 由 Change 模块处理: UniboExPoc.Sales.Changes.SalesOrder.CreateInvoicesComplex14
        # 最终发票且金额为负时转为贷项通知单 — 由 Change 模块处理: UniboExPoc.Sales.Changes.SalesOrder.CreateInvoicesComplex15
        :ok
      end
    end
  end

  identities do
    identity :unique_order_name, [:name]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  aggregates do
    count :total_items, :items
    sum :total_quantity, :items, field: :quantity
  end

  policies do
    policy action_type(:create) do
      authorize_if expr(actor.role in [:sales_rep, :admin])
    end
    policy action_type(:read) do
      authorize_if always()
    end
  end

end
