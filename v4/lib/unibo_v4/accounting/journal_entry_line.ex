# Workflow: journal_entry_line_editing — 分录行编辑流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> [*]
# ```
defmodule UniboV4.Accounting.JournalEntryLine do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Accounting,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "accounting_journal_entry_lines"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :debit_amount, :decimal do
      default 0
      public? true
    end
    attribute :credit_amount, :decimal do
      default 0
      public? true
    end
    attribute :balance, :decimal, public?: true
    attribute :amount_currency, :decimal, public?: true
    attribute :amount_residual, :decimal, public?: true
    attribute :amount_residual_currency, :decimal, public?: true
    attribute :display_type, :atom do
      constraints one_of: [:product, :tax, :payment_term, :rounding, :line_note, :line_section]
      public? true
    end
    attribute :description, :string, public?: true
    attribute :currency_id, :uuid, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :journal_entry, UniboV4.Accounting.JournalEntry do
      public? true
      allow_nil? false
    end
    belongs_to :gl_account, UniboV4.Accounting.GlAccount do
      public? true
      allow_nil? false
    end
    belongs_to :partner, UniboV4.Accounting.Partner do
      public? true
    end
    has_many :matched_debits, UniboV4.Accounting.PartialReconcile do
      public? true
      destination_attribute :debit_line_id
    end
    has_many :matched_credits, UniboV4.Accounting.PartialReconcile do
      public? true
      destination_attribute :credit_line_id
    end
    belongs_to :full_reconcile, UniboV4.Accounting.FullReconcile do
      public? true
    end
    many_to_many :tax_ids, UniboV4.Accounting.Tax do
      public? true
      through UniboV4.Accounting.JournalEntryLineTaxRel
    end
    belongs_to :tax_line, UniboV4.Accounting.Tax do
      public? true
    end
  end

  actions do
    create :create do
      primary? true
      accept [:debit_amount, :credit_amount, :amount_currency, :display_type, :description, :currency_id]
      argument :gl_account_id, :uuid, allow_nil?: false
      argument :journal_entry_id, :uuid, allow_nil?: false
      change manage_relationship(:journal_entry_id, :journal_entry, type: :append, on_lookup: :relate)
      change manage_relationship(:gl_account_id, :gl_account, type: :append, on_lookup: :relate)
      validate compare(:debit_amount, greater_than_or_equal_to: 0)
      # message: "借方金额不能为负"
      validate compare(:credit_amount, greater_than_or_equal_to: 0)
      # message: "贷方金额不能为负"
      change fn changeset, _context ->
        debit_amount = Ash.Changeset.get_attribute(changeset, :debit_amount)
        credit_amount = Ash.Changeset.get_attribute(changeset, :credit_amount)

        if debit_amount && credit_amount do
          Ash.Changeset.force_change_attribute(changeset, :balance, Decimal.sub(debit_amount, credit_amount))
        else
          changeset
        end
      end
    end
    update :update do
      primary? true
      accept [:debit_amount, :credit_amount, :amount_currency, :description]
      # skipped: validate compare :debit_amount (incompatible with bulk update atomic path)
      # skipped: validate compare :credit_amount (incompatible with bulk update atomic path)
      change fn changeset, _context ->
        debit_amount = Ash.Changeset.get_attribute(changeset, :debit_amount)
        credit_amount = Ash.Changeset.get_attribute(changeset, :credit_amount)

        if debit_amount && credit_amount do
          Ash.Changeset.force_change_attribute(changeset, :balance, Decimal.sub(debit_amount, credit_amount))
        else
          changeset
        end
      end
      require_atomic? false
    end
  end

end
