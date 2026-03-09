# Workflow: journal_entry_line_editing — 分录行编辑流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> [*]
# ```
defmodule UniboExPoc.Accounting.JournalEntryLine do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "凭证分录行"
  end

  postgres do
    table "accounting_journal_entry_lines"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_journal_entry_line

    mutations do
      create :create_accounting_journal_entry_line, :create
      update :update_accounting_journal_entry_line, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :debit_amount, :decimal do
      default 0
      public? true
      description "借方金额"
    end
    attribute :credit_amount, :decimal do
      default 0
      public? true
      description "贷方金额"
    end
    attribute :balance, :decimal do
      public? true
      description "计算字段: debit_amount - credit_amount"
    end
    attribute :amount_currency, :decimal do
      public? true
      description "外币金额"
    end
    attribute :amount_residual, :decimal do
      public? true
      description "未核销余额（本位币）"
    end
    attribute :amount_residual_currency, :decimal do
      public? true
      description "未核销外币余额"
    end
    attribute :display_type, :atom do
      constraints one_of: [:product, :tax, :payment_term, :rounding, :line_note, :line_section]
      public? true
      description "行类型（产品行、税行、付款条件行、舍入行、备注行、分节行）"
    end
    attribute :description, :string, public?: true
    attribute :currency_id, :uuid do
      public? true
      description "币种"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :journal_entry, UniboExPoc.Accounting.JournalEntry do
      public? true
      allow_nil? false
    end
    belongs_to :gl_account, UniboExPoc.Accounting.GlAccount do
      public? true
      allow_nil? false
    end
    belongs_to :partner, UniboExPoc.Accounting.Party do
      public? true
      source_attribute :partner_party_id
    end
    has_many :matched_debits, UniboExPoc.Accounting.PartialReconcile do
      public? true
      destination_attribute :debit_line_id
    end
    has_many :matched_credits, UniboExPoc.Accounting.PartialReconcile do
      public? true
      destination_attribute :credit_line_id
    end
    belongs_to :full_reconcile, UniboExPoc.Accounting.FullReconcile do
      public? true
    end
    many_to_many :tax_ids, UniboExPoc.Accounting.Tax do
      public? true
      through UniboExPoc.Accounting.JournalEntryLineTaxRel
    end
    belongs_to :tax_line, UniboExPoc.Accounting.Tax do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:debit_amount, :credit_amount, :amount_currency, :display_type, :description, :currency_id]
      argument :partner_id, :uuid
      argument :gl_account_id, :uuid, allow_nil?: false
      argument :journal_entry_id, :uuid, allow_nil?: false
      change manage_relationship(:journal_entry_id, :journal_entry, type: :append, on_lookup: :relate)
      change manage_relationship(:gl_account_id, :gl_account, type: :append, on_lookup: :relate)
      validate compare(:debit_amount, greater_than_or_equal_to: 0)
      # message: "借方金额不能为负"
      validate compare(:credit_amount, greater_than_or_equal_to: 0)
      # message: "贷方金额不能为负"
      change set_attribute(:balance, expr((debit_amount - credit_amount)))
    end
    update :update do
      primary? true
      accept [:debit_amount, :credit_amount, :amount_currency, :description]
      # skipped: validate compare :debit_amount (incompatible with bulk update atomic path)
      # skipped: validate compare :credit_amount (incompatible with bulk update atomic path)
      change set_attribute(:balance, expr((debit_amount - credit_amount)))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
