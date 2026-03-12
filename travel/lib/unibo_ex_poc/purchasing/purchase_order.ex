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
defmodule UniboExPoc.Purchasing.PurchaseOrder do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Purchasing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    authorizers: [Ash.Policy.Authorizer],
    notifiers: [UniboExPoc.Purchasing.PurchaseOrder.Notifier]

  resource do
    description "采购订单（状态机对齐 Odoo：draft/sent/to_approve/purchase/done/cancel）"
  end

  postgres do
    table "purchasing_purchase_orders"
    repo UniboExPoc.Repo
    identity_index_names unique_order_number: "idx_purchasing_purchase_orders_unique_order_number"
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
      description "订单编号（序列号自动生成）"
    end
    attribute :status, :atom do
      constraints one_of: [:draft, :sent, :to_approve, :purchase, :done, :cancel]
      default :draft
      public? true
      description "状态：draft=询价单草稿, sent=已发送RFQ, to_approve=待审批, purchase=采购订单, done=已锁定, cancel=已取消"
    end
    attribute :date_order, :utc_datetime do
      allow_nil? false
      public? true
      description "订单日期"
    end
    attribute :date_approve, :utc_datetime do
      public? true
      description "审批日期，审批时自动写入"
    end
    attribute :currency_id, :uuid do
      allow_nil? false
      public? true
      description "币种（关联 res.currency）"
    end
    attribute :fiscal_position_id, :uuid do
      public? true
      description "财务位置（关联 account.fiscal.position）"
    end
    attribute :payment_term_id, :uuid do
      public? true
      description "付款条款（关联 account.payment.term）"
    end
    attribute :receipt_status, :atom do
      constraints one_of: [:pending, :partial, :full]
      default :pending
      public? true
      description "收货状态（聚合计算）"
    end
    attribute :mail_reminder_confirmed, :boolean do
      default false
      public? true
      description "邮件提醒确认标记，取消时重置为 false"
    end
    attribute :shipping_address, :string, public?: true
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :amount_untaxed, :decimal, expr(sum(order_lines, field: :price_subtotal, query: [filter: expr(true)]))
    calculate :amount_tax, :decimal, expr(sum(order_lines, field: :price_tax, query: [filter: expr(true)]))
    calculate :amount_total, :decimal, expr((amount_untaxed + amount_tax))
    calculate :invoice_status, :atom, {UniboExPoc.Purchasing.Calculations.PurchaseOrder.InvoiceStatus, []}
    calculate :date_planned, :utc_datetime, {UniboExPoc.Purchasing.Calculations.PurchaseOrder.DatePlanned, []}
    calculate :currency_rate, :decimal, expr(amount_total)
    calculate :invoice_count, :integer, expr(count(invoices, query: [filter: expr(true)]))
    calculate :tax_country_id, :uuid, {UniboExPoc.Purchasing.Calculations.PurchaseOrder.TaxCountryId, []}
    calculate :tax_totals, :map, expr(tax_totals)
    calculate :item_count, :integer, expr(count(order_lines, query: [filter: expr(true)]))
  end

  relationships do
    has_many :order_lines, UniboExPoc.Purchasing.PurchaseOrderLine do
      public? true
      destination_attribute :order_id
    end
    belongs_to :supplier, UniboExPoc.Purchasing.Supplier do
      public? true
      allow_nil? false
    end
    belongs_to :company, UniboExPoc.Purchasing.Party do
      public? true
      source_attribute :company_party_id
    end
    belongs_to :created_by, UniboExPoc.Purchasing.Party do
      public? true
      source_attribute :created_by_party_id
    end
    has_many :receipts, UniboExPoc.Purchasing.GoodsReceipt do
      public? true
    end
    has_many :invoices, UniboExPoc.Purchasing.AccountMove do
      public? true
      destination_attribute :purchase_order_id
    end
    belongs_to :requisition, UniboExPoc.Purchasing.PurchaseRequisition do
      public? true
    end
    has_many :inbound_cross_org_transactions, UniboExPoc.Delivery.CrossOrgTransaction do
      public? true
      destination_attribute :target_purchase_order_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      description "Create Purchase Order via Create. doc_url: graphql://contract/purchasing/create_create_purchasing_purchase_order"
      primary? true
      accept [:name, :date_order, :currency_id, :fiscal_position_id, :payment_term_id, :shipping_address, :notes]
      argument :date_planned, :utc_datetime
      argument :company_id, :uuid
      argument :order_lines, {:array, :string}, allow_nil?: false
      argument :supplier_id, :uuid, allow_nil?: false
      change manage_relationship(:order_lines, :order_lines, type: :create)
      change manage_relationship(:supplier_id, :supplier, type: :append, on_lookup: :relate)
      validate present(:name)
      # validation: check_order_line_company_id — 订单行中产品的公司必须与订单公司一致
      # validation: supplier_purchase_warn_block — 该供应商已被设置为采购阻止，无法选择
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
    update :update do
      description "Update Purchase Order via Update. doc_url: graphql://contract/purchasing/update_purchasing_purchase_order"
      primary? true
      accept [:date_order, :fiscal_position_id, :payment_term_id, :shipping_address, :notes]
      argument :date_planned, :utc_datetime
      argument :order_lines, {:array, :map}, default: []
      change manage_relationship(:order_lines, :order_lines, on_lookup: :relate, on_no_match: :create, on_match: :update)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      require_atomic? false
    end
    update :print_quotation do
      description "打印报价单（RFQ），副作用将 draft 转为 sent

打印报价单（RFQ），副作用将 draft 转为 sent. doc_url: graphql://contract/purchasing/print_quotation_purchasing_purchase_order"
      accept []
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
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
      require_atomic? false
    end
    update :send_rfq do
      description "通过邮件发送 RFQ 给供应商

通过邮件发送 RFQ 给供应商. doc_url: graphql://contract/purchasing/send_rfq_purchasing_purchase_order"
      accept []
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      require_atomic? false
    end
    update :button_confirm do
      description "确认订单（根据审批路由进入 purchase 或 to_approve）

确认订单（根据审批路由进入 purchase 或 to_approve）. doc_url: graphql://contract/purchasing/button_confirm_purchasing_purchase_order"
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
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change UniboExPoc.Purchasing.Changes.PurchaseOrder.ComputeStatus
      change UniboExPoc.Purchasing.Changes.PurchaseOrder.ButtonConfirmCall12
      change UniboExPoc.Purchasing.Changes.PurchaseOrder.ButtonConfirmCall13
      require_atomic? false
    end
    update :button_approve do
      description "审批通过（管理员操作或自动审批）

审批通过（管理员操作或自动审批）. doc_url: graphql://contract/purchasing/button_approve_purchasing_purchase_order"
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
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:status, :purchase)
      change UniboExPoc.Purchasing.Changes.PurchaseOrder.ComputeDateApprove
      change UniboExPoc.Purchasing.Changes.PurchaseOrder.ComputeStatus
      require_atomic? false
    end
    update :button_done do
      description "锁定订单

锁定订单. doc_url: graphql://contract/purchasing/button_done_purchasing_purchase_order"
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
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:status, :done)
      require_atomic? false
    end
    update :button_unlock do
      description "解锁订单（done -> purchase）

解锁订单（done -> purchase）. doc_url: graphql://contract/purchasing/button_unlock_purchasing_purchase_order"
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
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:status, :purchase)
      require_atomic? false
    end
    update :button_cancel do
      description "取消订单

取消订单. doc_url: graphql://contract/purchasing/button_cancel_purchasing_purchase_order"
      accept []
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:status, :cancel)
      change set_attribute(:mail_reminder_confirmed, false)
      require_atomic? false
    end
    update :button_draft do
      description "重置为草稿

重置为草稿. doc_url: graphql://contract/purchasing/button_draft_purchasing_purchase_order"
      accept []
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:status, :draft)
      require_atomic? false
    end
    create :action_create_invoice do
      description "从采购单创建供应商发票

从采购单创建供应商发票. doc_url: graphql://contract/purchasing/create_action_create_invoice_purchasing_purchase_order"
      accept []
      argument :order_lines, {:array, :map}, default: []
      change manage_relationship(:order_lines, :order_lines, type: :create)
      argument :supplier_id, :uuid, allow_nil?: false
      change manage_relationship(:supplier_id, :supplier, type: :append, on_lookup: :relate)
      validate present(:name)
      # validation: check_order_line_company_id — 订单行中产品的公司必须与订单公司一致
      # validation: supplier_purchase_warn_block — 该供应商已被设置为采购阻止，无法选择
      # precondition: requires invoice_status=:to_invoice
      validate attribute_equals(:invoice_status, :to_invoice)
      change relate_actor(:created_by)
      change UniboExPoc.Purchasing.Changes.PurchaseOrder.ActionCreateInvoiceCall14
      change UniboExPoc.Purchasing.Changes.PurchaseOrder.ActionCreateInvoiceCall15
    end
  end

  identities do
    identity :unique_order_number, [:name]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  aggregates do
    count :total_lines, :order_lines
    sum :total_quantity, :order_lines, field: :quantity
    sum :total_received, :order_lines, field: :qty_received
    sum :total_invoiced, :order_lines, field: :qty_invoiced
  end

  policies do
    policy action_type(:read) do
      authorize_if expr(^actor(:role) == :admin)
      authorize_if relates_to_actor_via(:company)
    end
    policy action_type(:update) do
      authorize_if expr(^actor(:role) == :admin)
      authorize_if relates_to_actor_via(:company)
    end
    policy action_type(:create) do
      authorize_if expr(actor.role in [:buyer, :admin])
    end
    policy action(:button_approve) do
      authorize_if expr(^actor(:role) == :purchase_manager or unknown_func())
    end
  end

end
