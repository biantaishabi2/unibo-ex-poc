# Workflow: payment_lifecycle — 付款处理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> post
#   post --> cancel
#   cancel --> reset_to_draft
#   reset_to_draft --> post
# ```
defmodule UniboV4.Accounting.Payment do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Accounting,
    data_layer: AshPostgres.DataLayer,
    notifiers: [UniboV4.Accounting.Payment.Notifier]

  postgres do
    table "accounting_payments"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :payment_number, :string do
      allow_nil? false
      public? true
    end
    attribute :payment_type, :atom do
      allow_nil? false
      constraints one_of: [:inbound, :outbound]
      public? true
    end
    attribute :partner_type, :atom do
      constraints one_of: [:customer, :supplier]
      public? true
    end
    attribute :status, :atom do
      constraints one_of: [:draft, :posted, :cancel]
      default :draft
      public? true
    end
    attribute :amount, :decimal do
      allow_nil? false
      public? true
    end
    attribute :currency, :string do
      default "CNY"
      public? true
    end
    attribute :payment_date, :date do
      allow_nil? false
      public? true
    end
    attribute :payment_method, :atom do
      constraints one_of: [:manual, :check, :bank_transfer, :cash, :credit_card, :sepa, :batch_deposit, :other]
      public? true
    end
    attribute :destination_account_id, :uuid, public?: true
    attribute :reference_number, :string, public?: true
    attribute :is_reconciled, :boolean do
      default false
      public? true
    end
    attribute :is_matched, :boolean do
      default false
      public? true
    end
    attribute :paired_internal_transfer_payment_id, :uuid, public?: true
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :journal_entry, UniboV4.Accounting.JournalEntry do
      public? true
      allow_nil? false
    end
    has_many :applications, UniboV4.Accounting.PaymentApplication do
      public? true
    end
    belongs_to :created_by, UniboV4.Accounting.User do
      public? true
    end
    belongs_to :paired_internal_transfer, UniboV4.Accounting.Payment do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:payment_number, :payment_type, :partner_type, :amount, :currency, :payment_date, :payment_method, :destination_account_id, :reference_number, :notes]
      argument :journal_entry_id, :uuid, allow_nil?: false
      change manage_relationship(:journal_entry_id, :journal_entry, type: :append, on_lookup: :relate)
      validate present(:payment_number)
      validate compare(:amount, greater_than_or_equal_to: 0)
      # message: "[R-PAY-001] 付款金额不能为负"
      # TODO: 不支持的 action 内校验规则 custom
      change relate_actor(:created_by)
    end
    update :post do
      accept []
      # skipped: validate compare :amount (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以确认"
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:status, :posted)
      # TODO: 不支持的 change effect custom
      # TODO: 不支持的 change effect custom
      require_atomic? false
    end
    update :cancel do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :posted do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :posted}))
        end
      end
      # message: "只有已过账状态可以取消"
      change set_attribute(:status, :cancel)
      require_atomic? false
    end
    update :reset_to_draft do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :cancel do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :cancel}))
        end
      end
      # message: "只有已取消状态可以重置为草稿"
      change set_attribute(:status, :draft)
      require_atomic? false
    end
  end

  identities do
    identity :unique_payment_number, [:payment_number]
  end

end
