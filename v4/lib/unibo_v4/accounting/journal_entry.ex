# Workflow: journal_entry_lifecycle — 凭证过账流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> post
#   post --> cancel
#   post --> reset_to_draft
#   cancel --> reset_to_draft
#   reset_to_draft --> post
# ```
defmodule UniboV4.Accounting.JournalEntry do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Accounting.JournalEntry.Notifier]

  postgres do
    table "accounting_journal_entries"
    repo UniboV4.Repo
  end

  graphql do
    type :accounting_journal_entry

    queries do
      get :get_accounting_journal_entry, :read
      list :list_accounting_journal_entrys, :read
    end

    mutations do
      create :create_accounting_journal_entry, :create
      update :post_accounting_journal_entry, :post
      update :cancel_accounting_journal_entry, :cancel
      update :reset_to_draft_accounting_journal_entry, :reset_to_draft
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :entry_number, :string do
      allow_nil? false
      public? true
    end
    attribute :move_type, :atom do
      constraints one_of: [:entry, :out_invoice, :out_refund, :in_invoice, :in_refund, :out_receipt, :in_receipt]
      default :entry
      public? true
    end
    attribute :status, :atom do
      constraints one_of: [:draft, :posted, :cancel]
      default :draft
      public? true
    end
    attribute :entry_date, :date do
      allow_nil? false
      public? true
    end
    attribute :invoice_date, :date, public?: true
    attribute :invoice_date_due, :date, public?: true
    attribute :description, :string, public?: true
    attribute :journal_id, :uuid, public?: true
    attribute :currency_id, :uuid, public?: true
    attribute :partner_id, :uuid, public?: true
    attribute :fiscal_position_id, :uuid, public?: true
    attribute :invoice_origin, :string, public?: true
    attribute :ref, :string, public?: true
    attribute :amount_untaxed, :decimal, public?: true
    attribute :amount_tax, :decimal, public?: true
    attribute :amount_total, :decimal, public?: true
    attribute :amount_residual, :decimal, public?: true
    attribute :amount_residual_signed, :decimal, public?: true
    attribute :payment_state, :atom do
      constraints one_of: [:not_paid, :partial, :in_payment, :paid, :reversed, :invoicing_legacy]
      public? true
    end
    attribute :total_debit, :decimal, public?: true
    attribute :total_credit, :decimal, public?: true
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :lines, UniboV4.Accounting.JournalEntryLine do
      public? true
    end
    belongs_to :created_by, UniboV4.Accounting.User do
      public? true
    end
    belongs_to :journal, UniboV4.Accounting.Journal do
      public? true
    end
    belongs_to :partner, UniboV4.Accounting.Partner do
      public? true
    end
    belongs_to :tax_cash_basis_origin, UniboV4.Accounting.JournalEntry do
      public? true
    end
    has_many :tax_cash_basis_created_moves, UniboV4.Accounting.JournalEntry do
      public? true
      destination_attribute :tax_cash_basis_origin_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:entry_number, :move_type, :entry_date, :invoice_date, :invoice_date_due, :description, :notes, :journal_id, :currency_id, :partner_id, :fiscal_position_id, :invoice_origin, :ref]
      argument :lines, {:array, :map}, allow_nil?: false
      change manage_relationship(:lines, :lines, type: :create)
      validate present(:entry_number)
      change relate_actor(:created_by)
      # TODO: 跨实体聚合表达式暂不支持
      # TODO: 跨实体聚合表达式暂不支持
      # TODO: 跨实体聚合表达式暂不支持
      # TODO: 跨实体聚合表达式暂不支持
      change fn changeset, _context ->
        amount_untaxed = Ash.Changeset.get_attribute(changeset, :amount_untaxed)
        amount_tax = Ash.Changeset.get_attribute(changeset, :amount_tax)

        if amount_untaxed && amount_tax do
          Ash.Changeset.force_change_attribute(changeset, :amount_total, Decimal.add(amount_untaxed, amount_tax))
        else
          changeset
        end
      end
    end
    update :post do
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
      # message: "只有草稿凭证可以过账"
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # TODO: 跨实体聚合表达式暂不支持
      # TODO: 跨实体聚合表达式暂不支持
      change fn changeset, _context ->
        amount_untaxed = Ash.Changeset.get_attribute(changeset, :amount_untaxed)
        amount_tax = Ash.Changeset.get_attribute(changeset, :amount_tax)

        if amount_untaxed && amount_tax do
          Ash.Changeset.force_change_attribute(changeset, :amount_total, Decimal.add(amount_untaxed, amount_tax))
        else
          changeset
        end
      end
      change set_attribute(:status, :posted)
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
      # message: "只有已过账凭证可以取消"
      change set_attribute(:status, :cancel)
      require_atomic? false
    end
    update :reset_to_draft do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:cancel, :posted] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:cancel, :posted]}))
        end
      end
      # message: "只有已取消或已过账凭证可以重置为草稿"
      change set_attribute(:status, :draft)
      require_atomic? false
    end
  end

  identities do
    identity :unique_entry_number_when_posted, [:entry_number, :journal_id]
  end

end
