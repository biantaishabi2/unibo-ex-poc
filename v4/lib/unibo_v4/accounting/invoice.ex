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
defmodule UniboV4.Accounting.Invoice do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Accounting,
    data_layer: AshPostgres.DataLayer,
    notifiers: [UniboV4.Accounting.Invoice.Notifier]

  postgres do
    table "accounting_invoices"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :invoice_number, :string do
      allow_nil? false
      public? true
    end
    attribute :invoice_type, :atom do
      allow_nil? false
      constraints one_of: [:sales_invoice, :purchase_invoice, :credit_memo, :debit_memo]
      public? true
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
    attribute :due_date, :date, public?: true
    attribute :total_amount, :decimal, public?: true
    attribute :paid_amount, :decimal do
      default 0
      public? true
    end
    attribute :currency, :string do
      default "CNY"
      public? true
    end
    attribute :invoice_origin, :string, public?: true
    attribute :description, :string, public?: true
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :items, UniboV4.Accounting.InvoiceItem do
      public? true
    end
    has_many :payments, UniboV4.Accounting.PaymentApplication do
      public? true
    end
    belongs_to :created_by, UniboV4.Accounting.User do
      public? true
    end
    belongs_to :journal_entry, UniboV4.Accounting.JournalEntry do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:invoice_number, :invoice_type, :invoice_date, :due_date, :currency, :description, :notes, :invoice_origin]
      argument :items, {:array, :string}, allow_nil?: false
      change manage_relationship(:items, :items, type: :create)
      validate present(:invoice_number)
      change relate_actor(:created_by)
      # TODO: 跨实体聚合表达式暂不支持
    end
    update :approve do
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
