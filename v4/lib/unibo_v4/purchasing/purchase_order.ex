# Workflow: procurement_flow — 采购全流程（对齐 Odoo 状态机）
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> print_quotation
#   create --> send_rfq
#   create --> button_confirm
#   print_quotation --> button_confirm
#   print_quotation --> button_cancel
#   print_quotation --> button_draft
#   send_rfq --> button_confirm
#   send_rfq --> button_cancel
#   send_rfq --> button_draft
#   button_confirm --> button_approve
#   button_confirm --> button_done
#   button_confirm --> button_cancel
#   button_confirm --> action_create_invoice
#   button_approve --> button_done
#   button_approve --> button_cancel
#   button_approve --> action_create_invoice
#   button_done --> button_unlock
#   button_unlock --> button_done
#   button_unlock --> button_cancel
#   button_unlock --> action_create_invoice
#   button_cancel --> button_draft
#   button_draft --> print_quotation
#   button_draft --> send_rfq
#   button_draft --> button_confirm
#   action_create_invoice --> [*] : invoice_created
# ```
# Workflow: purchase_order_editing — 采购订单草稿编辑流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> update
#   update --> send_rfq
#   update --> button_confirm
# ```
defmodule UniboV4.Purchasing.PurchaseOrder do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Purchasing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    authorizers: [Ash.Policy.Authorizer],
    notifiers: [UniboV4.Purchasing.PurchaseOrder.Notifier]

  postgres do
    table "purchasing_purchase_orders"
    repo UniboV4.Repo
  end

  graphql do
    type :purchasing_purchase_order

    queries do
      get :get_purchasing_purchase_order, :read
      list :list_purchasing_purchase_orders, :read
      get :get_list_purchasing_purchase_order, :list
      list :list_list_purchasing_purchase_orders, :list
      get :get_search_purchasing_purchase_order, :search
      list :list_search_purchasing_purchase_orders, :search
      get :get_get_purchasing_purchase_order, :get
      list :list_get_purchasing_purchase_orders, :get
      get :get_preview_purchasing_purchase_order, :preview
      list :list_preview_purchasing_purchase_orders, :preview
      get :get_compute_purchasing_purchase_order, :compute
      list :list_compute_purchasing_purchase_orders, :compute
      get :get_lookup_purchasing_purchase_order, :lookup
      list :list_lookup_purchasing_purchase_orders, :lookup
    end

    mutations do
      create :create_create_purchasing_purchase_order, :create
      create :create_action_create_invoice_purchasing_purchase_order, :action_create_invoice
      update :update_purchasing_purchase_order, :update
      update :print_quotation_purchasing_purchase_order, :print_quotation
      update :send_rfq_purchasing_purchase_order, :send_rfq
      update :button_confirm_purchasing_purchase_order, :button_confirm
      update :button_approve_purchasing_purchase_order, :button_approve
      update :button_done_purchasing_purchase_order, :button_done
      update :button_unlock_purchasing_purchase_order, :button_unlock
      update :button_cancel_purchasing_purchase_order, :button_cancel
      update :button_draft_purchasing_purchase_order, :button_draft
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :status, :atom do
      constraints one_of: [:draft, :sent, :to_approve, :purchase, :done, :cancel]
      default :draft
      public? true
    end
    attribute :date_order, :utc_datetime do
      allow_nil? false
      public? true
    end
    attribute :date_approve, :utc_datetime, public?: true
    attribute :currency_id, :uuid do
      allow_nil? false
      public? true
    end
    attribute :company_id, :uuid do
      allow_nil? false
      public? true
    end
    attribute :fiscal_position_id, :uuid, public?: true
    attribute :payment_term_id, :uuid, public?: true
    attribute :receipt_status, :atom do
      constraints one_of: [:pending, :partial, :full]
      default :pending
      public? true
    end
    attribute :mail_reminder_confirmed, :boolean do
      default false
      public? true
    end
    attribute :shipping_address, :string, public?: true
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :amount_untaxed, :decimal, expr(sum(order_lines, field: :price_subtotal, query: [filter: expr(true)]))
    calculate :amount_tax, :decimal, expr(sum(order_lines, field: :price_tax, query: [filter: expr(true)]))
    # TODO: 不支持的 calculation 表达式 :amount_total
    # TODO: 不支持的 calculation 表达式 :invoice_status
    # TODO: 不支持的 calculation 表达式 :date_planned
    # TODO: 不支持的 calculation 表达式 :currency_rate
    calculate :invoice_count, :integer, expr(count(invoices, query: [filter: expr(true)]))
    # TODO: 不支持的 calculation 表达式 :tax_country_id
    # TODO: 不支持的 calculation 表达式 :tax_totals
    calculate :item_count, :integer, expr(count(order_lines, query: [filter: expr(true)]))
  end

  relationships do
    has_many :order_lines, UniboV4.Purchasing.PurchaseOrderLine do
      public? true
      destination_attribute :order_id
    end
    belongs_to :supplier, UniboV4.Purchasing.Supplier do
      public? true
      allow_nil? false
    end
    belongs_to :created_by, UniboV4.Purchasing.User do
      public? true
    end
    has_many :receipts, UniboV4.Purchasing.GoodsReceipt do
      public? true
    end
    has_many :invoices, UniboV4.Purchasing.AccountMove do
      public? true
      destination_attribute :purchase_order_id
    end
    belongs_to :requisition, UniboV4.Purchasing.PurchaseRequisition do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :date_order, :currency_id, :company_id, :fiscal_position_id, :payment_term_id, :shipping_address, :notes]
      argument :date_planned, :utc_datetime
      argument :order_lines, {:array, :map}, allow_nil?: false
      argument :supplier_id, :uuid, allow_nil?: false
      change manage_relationship(:order_lines, :order_lines, type: :create)
      change manage_relationship(:supplier_id, :supplier, type: :append, on_lookup: :relate)
      validate present(:name)
      # TODO: 不支持的 action 内校验规则 custom
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
    update :update do
      primary? true
      accept [:date_order, :fiscal_position_id, :payment_term_id, :shipping_address, :notes]
      argument :date_planned, :utc_datetime
      argument :order_lines, {:array, :map}, default: []
      change manage_relationship(:order_lines, :order_lines, on_lookup: :relate, on_no_match: :create, on_match: :update)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
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
    update :print_quotation do
      accept []
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以打印报价单"
      change set_attribute(:status, :sent)
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
    update :send_rfq do
      accept []
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
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
    update :button_confirm do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:draft, :sent] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:draft, :sent]}))
        end
      end
      # message: "只有草稿或已发送状态可以确认"
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # TODO: 不支持的表达式类型
      # TODO: 不支持的 change effect call
      # TODO: 不支持的 change effect call
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
    update :button_approve do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :to_approve do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :to_approve}))
        end
      end
      # message: "只有待审批状态可以审批通过"
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:status, :purchase)
      # TODO: 跨实体聚合表达式暂不支持
      # TODO: 不支持的表达式类型
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
    update :button_done do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :purchase do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :purchase}))
        end
      end
      # message: "只有采购订单状态可以锁定"
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:status, :done)
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
    update :button_unlock do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :done do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :done}))
        end
      end
      # message: "只有已锁定状态可以解锁"
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:status, :purchase)
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
    update :button_cancel do
      accept []
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:status, :cancel)
      change set_attribute(:mail_reminder_confirmed, false)
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
    update :button_draft do
      accept []
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:status, :draft)
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
    create :action_create_invoice do
      accept []
      argument :order_lines, {:array, :map}, default: []
      change manage_relationship(:order_lines, :order_lines, type: :create)
      argument :supplier_id, :uuid, allow_nil?: false
      change manage_relationship(:supplier_id, :supplier, type: :append, on_lookup: :relate)
      validate present(:name)
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: 不支持的 action 内校验规则 custom
      validate attribute_equals(:invoice_status, :to_invoice)
      # message: "当前无待开票内容，无法创建发票"
      change relate_actor(:created_by)
      # TODO: 不支持的 change effect call
      # TODO: 不支持的 change effect call
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
  end

  identities do
    identity :unique_order_number, [:name]
  end

  aggregates do
    count :total_lines, :order_lines
    sum :total_quantity, :order_lines, field: :product_qty
    sum :total_received, :order_lines, field: :qty_received
    sum :total_invoiced, :order_lines, field: :qty_invoiced
  end

  policies do
    policy action_type(:create) do
      # TODO: role 字段尚未定义，暂时放开
      authorize_if always()
    end
    policy action_type(:read) do
      authorize_if always()
    end
    policy action_type(:update) do
      # TODO: role 字段尚未定义，暂时放开
      authorize_if always()
    end
    policy action(:button_approve) do
      # TODO: role 字段尚未定义，暂时放开
      authorize_if always()
    end
  end

end
