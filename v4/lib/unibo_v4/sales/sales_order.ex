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
defmodule UniboV4.Sales.SalesOrder do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Sales,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    authorizers: [Ash.Policy.Authorizer],
    notifiers: [UniboV4.Sales.SalesOrder.Notifier]

  postgres do
    table "sales_sales_orders"
    repo UniboV4.Repo
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
    end
    attribute :state, :atom do
      constraints one_of: [:draft, :sent, :sale, :done, :cancel]
      default :draft
      public? true
    end
    attribute :locked, :boolean do
      default false
      public? true
    end
    attribute :date_order, :utc_datetime do
      allow_nil? false
      default &DateTime.utc_now/0
      public? true
    end
    attribute :promised_delivery_date, :date, public?: true
    attribute :currency, :string do
      default "CNY"
      public? true
    end
    attribute :payment_terms, :string, public?: true
    attribute :shipping_address, :string, public?: true
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :amount_untaxed, :decimal, expr(sum(items, field: :price_subtotal, query: [filter: expr(true)]))
    calculate :amount_tax, :decimal, expr(sum(items, field: :price_tax, query: [filter: expr(true)]))
    # TODO: 不支持的 calculation 表达式 :amount_total
    # TODO: 不支持的 calculation 表达式 :invoice_status
    calculate :item_count, :integer, expr(count(items, query: [filter: expr(true)]))
  end

  relationships do
    has_many :items, UniboV4.Sales.SalesOrderItem do
      public? true
      destination_attribute :order_id
    end
    belongs_to :customer, UniboV4.Sales.Customer do
      public? true
      allow_nil? false
    end
    belongs_to :shipping_partner, UniboV4.Sales.Customer do
      public? true
      allow_nil? false
    end
    belongs_to :created_by, UniboV4.Sales.User do
      public? true
    end
    has_many :shipments, UniboV4.Sales.SalesOrderShipment do
      public? true
    end
    has_many :returns, UniboV4.Sales.Return do
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
      # TODO: 不支持的 action 内校验规则 custom
      change relate_actor(:created_by)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    read :list do
    end
    read :search do
    end
    read :get do
    end
    read :preview do
    end
    read :compute do
    end
    read :lookup do
    end
    update :action_quotation_send do
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
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :action_confirm do
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
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:state, :sale)
      change set_attribute(:date_order, &DateTime.utc_now/0)
      # TODO: 不支持的 change effect create_related
      # TODO: 不支持的 change effect subscribe_partner
      change set_attribute(:locked, true)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :action_done do
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
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :action_cancel do
      accept []
      # skipped: validate compare :locked (incompatible with bulk update atomic path)
      # TODO: 不支持的 change effect cancel_related
      # TODO: 不支持的 change effect cancel_related
      change set_attribute(:state, :cancel)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :action_draft do
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
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    action :create_invoices do
      argument :final, :boolean
      validate attribute_equals(:state, :sale)
      # message: "只能对已确认订单创建发票"
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: generic action 不支持 change，需要用 run
    end
  end

  identities do
    identity :unique_order_name, [:name]
  end

  aggregates do
    count :total_items, :items
    sum :total_quantity, :items, field: :product_uom_qty
  end

  policies do
    policy action_type(:create) do
      authorize_if expr(role in [:sales_rep, :admin])
    end
    policy action_type(:read) do
      authorize_if always()
    end
  end

end
