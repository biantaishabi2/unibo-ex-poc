# Workflow: invoice_lifecycle — 发票生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> approve
#   create --> void
#   approve --> send
#   approve --> void
#   send --> [*] : sent
#   void --> [*]
# ```
defmodule UniboExPoc.Accounting.Invoice do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboExPoc.Accounting.Invoice.Notifier]

  resource do
    description "发票（应收/应付）— 业务视图，底层映射为 JournalEntry（move_type = out_invoice/in_invoice 等）"
  end

  postgres do
    table "accounting_invoices"
    repo UniboExPoc.Repo
    identity_index_names unique_invoice_number: "idx_accounting_invoices_unique_invoice_number"
  end

  graphql do
    type :accounting_invoice

    queries do
      get :get_accounting_invoice, :read
      list :list_accounting_invoices, :read
    end

    mutations do
      create :create_accounting_invoice, :create
      update :approve_accounting_invoice, :approve
      update :send_accounting_invoice, :send
      update :void_accounting_invoice, :void
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :invoice_number, :string do
      allow_nil? false
      public? true
      description "发票号"
    end
    attribute :invoice_type, :atom do
      allow_nil? false
      constraints one_of: [:sales_invoice, :purchase_invoice, :credit_memo, :debit_memo]
      public? true
      description "发票类型"
    end
    attribute :status, :atom do
      constraints one_of: [:draft, :approved, :sent, :paid, :partially_paid, :cancelled, :void]
      default :draft
      public? true
    end
    attribute :invoice_date, :date do
      allow_nil? false
      public? true
    end
    attribute :due_date, :date do
      public? true
      description "到期日"
    end
    attribute :total_amount, :decimal do
      public? true
      description "发票总金额"
    end
    attribute :paid_amount, :decimal do
      default 0
      public? true
      description "已付金额"
    end
    attribute :currency, :string do
      default "CNY"
      public? true
    end
    attribute :invoice_origin, :string do
      public? true
      description "来源单据号（SO/PO 编号），跨模块调用时由 sale/purchase 模块设置"
    end
    attribute :description, :string, public?: true
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :items, UniboExPoc.Accounting.InvoiceItem do
      public? true
    end
    has_many :payments, UniboExPoc.Accounting.PaymentApplication do
      public? true
    end
    belongs_to :created_by, UniboExPoc.Accounting.Party do
      public? true
      source_attribute :created_by_party_id
    end
    belongs_to :journal_entry, UniboExPoc.Accounting.JournalEntry do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      description "Create Invoice via Create. doc_url: graphql://contract/accounting/create_accounting_invoice"
      primary? true
      accept [:invoice_number, :invoice_type, :invoice_date, :due_date, :currency, :description, :notes, :invoice_origin]
      argument :items, {:array, :string}, allow_nil?: false
      change manage_relationship(:items, :items, type: :create)
      validate present(:invoice_number)
      change relate_actor(:created_by)
      change UniboExPoc.Accounting.Changes.Invoice.ComputeTotalAmount
    end
    update :approve do
      description "审批发票

审批发票. doc_url: graphql://contract/accounting/approve_accounting_invoice"
      primary? true
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿发票可以审批"
      change set_attribute(:status, :approved)
      require_atomic? false
    end
    update :send do
      description "发送发票

发送发票. doc_url: graphql://contract/accounting/send_accounting_invoice"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :approved do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :approved}))
        end
      end
      # message: "只有已审批发票可以发送"
      change set_attribute(:status, :sent)
      require_atomic? false
    end
    update :void do
      description "作废发票

作废发票. doc_url: graphql://contract/accounting/void_accounting_invoice"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:draft, :approved] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:draft, :approved]}))
        end
      end
      # message: "只有草稿或已审批发票可以作废"
      change set_attribute(:status, :void)
      require_atomic? false
    end
  end

  identities do
    identity :unique_invoice_number, [:invoice_number]
  end

end
