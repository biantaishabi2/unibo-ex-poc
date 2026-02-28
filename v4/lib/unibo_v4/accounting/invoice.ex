defmodule UniboV4.Accounting.Invoice do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Accounting.Invoice.Notifier]

  postgres do
    table "invoices"
    repo UniboV4.Repo
  end

  graphql do
    type :invoice

    queries do
      get :get_invoice, :read
      list :list_invoices, :read
    end

    mutations do
      create :create_invoice, :create
      update :approve_invoice, :approve
      update :send_invoice, :send
      update :void_invoice, :void
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :invoice_number, :string, allow_nil?: false
    attribute :invoice_type, :atom do
      allow_nil? false
      constraints one_of: [:sales_invoice, :purchase_invoice, :credit_memo, :debit_memo]
    end
    attribute :status, :atom do
      constraints one_of: [:draft, :approved, :sent, :paid, :partially_paid, :cancelled, :void]
      default :draft
    end
    attribute :invoice_date, :date, allow_nil?: false
    attribute :due_date, :date
    attribute :total_amount, :decimal
    attribute :paid_amount, :decimal, default: 0
    attribute :currency, :string, default: "CNY"
    attribute :description, :string
    attribute :notes, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :items, UniboV4.Accounting.InvoiceItem
    has_many :payments, UniboV4.Accounting.PaymentApplication
    belongs_to :created_by, UniboV4.Accounts.User
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:invoice_number, :invoice_type, :invoice_date, :due_date, :currency, :description, :notes]
      argument :items, {:array, :string}, allow_nil?: false
      change manage_relationship(:items, :items, type: :create)
      validate present(:invoice_number)
      change relate_actor(:created_by)
      # TODO: 跨实体聚合表达式暂不支持
    end
    update :approve do
      accept []
      argument :items, {:array, :map}, default: []
      change manage_relationship(:items, :items, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_equals(:status, :draft) do
        message "只有草稿发票可以审批"
      end
      change set_attribute(:status, :approved)
    end
    update :send do
      accept []
      argument :items, {:array, :map}, default: []
      change manage_relationship(:items, :items, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_equals(:status, :approved) do
        message "只有已审批发票可以发送"
      end
      change set_attribute(:status, :sent)
    end
    update :void do
      accept []
      argument :items, {:array, :map}, default: []
      change manage_relationship(:items, :items, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_in(:status, [:draft, :approved]) do
        message "只有草稿或已审批发票可以作废"
      end
      change set_attribute(:status, :void)
    end
  end

  identities do
    identity :unique_invoice_number, [:invoice_number]
  end

end
