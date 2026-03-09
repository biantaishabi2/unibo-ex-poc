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
defmodule UniboExPoc.Accounting.JournalEntry do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.Accounting.JournalEntry.Notifier]

  resource do
    description "记账凭证（会计分录），涵盖普通凭证、销售发票、采购账单、收据等"
  end

  postgres do
    table "accounting_journal_entries"
    repo UniboExPoc.Repo
    identity_index_names unique_entry_number_when_posted: "idx_accounting_journal_entries_unique_entry_number_when_posted"
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
      description "凭证号，草稿时为 '/'，过账时由 journal sequence 生成 [R-ACC-007]"
    end
    attribute :move_type, :atom do
      constraints one_of: [:entry, :out_invoice, :out_refund, :in_invoice, :in_refund, :out_receipt, :in_receipt]
      default :entry
      public? true
      description "凭证类型"
    end
    attribute :status, :atom do
      constraints one_of: [:draft, :posted, :cancel]
      default :draft
      public? true
      description "凭证状态（draft → posted → cancel，cancel → draft）"
    end
    attribute :entry_date, :date do
      allow_nil? false
      public? true
      description "会计日期 [R-ACC-002]"
    end
    attribute :invoice_date, :date do
      public? true
      description "发票日期（仅 invoice 类型使用）[R-ACC-005]"
    end
    attribute :invoice_date_due, :date do
      public? true
      description "到期日"
    end
    attribute :description, :string, public?: true
    attribute :currency_id, :uuid do
      public? true
      description "币种"
    end
    attribute :fiscal_position_id, :uuid do
      public? true
      description "税务位置 [R-ACC-004]"
    end
    attribute :invoice_origin, :string do
      public? true
      description "来源单据号（SO/PO 编号）"
    end
    attribute :ref, :string do
      public? true
      description "参考号"
    end
    attribute :amount_untaxed, :decimal do
      public? true
      description "未税合计（计算字段）
公式: sign * SUM(line.balance) WHERE line.display_type IN ('product','rounding')
sign = +1（出站）或 -1（入站）[R-DIR-001][R-DIR-002][R-DIR-003]
"
    end
    attribute :amount_tax, :decimal do
      public? true
      description "税额合计（计算字段）
公式: sign * SUM(line.balance) WHERE line.display_type = 'tax'
"
    end
    attribute :amount_total, :decimal do
      public? true
      description "含税合计（计算字段）
公式: amount_untaxed + amount_tax
"
    end
    attribute :amount_residual, :decimal do
      public? true
      description "未付余额（计算字段）
公式: -sign * SUM(line.amount_residual_currency) WHERE line.display_type = 'payment_term'
"
    end
    attribute :amount_residual_signed, :decimal do
      public? true
      description "已签署未付余额（计算字段）
公式: SUM(line.amount_residual) WHERE line.display_type = 'payment_term'
"
    end
    attribute :payment_state, :atom do
      constraints one_of: [:not_paid, :partial, :in_payment, :paid, :reversed, :invoicing_legacy]
      public? true
      description "付款状态（计算字段）[R-REC-004]
not_paid: 无核销记录
partial: 存在核销但 amount_residual != 0
in_payment: amount_residual = 0 但部分付款未匹配银行对账单
paid: amount_residual = 0 且所有付款已匹配银行对账单
reversed: 仅冲销分录匹配
"
    end
    attribute :total_debit, :decimal do
      public? true
      description "借方合计"
    end
    attribute :total_credit, :decimal do
      public? true
      description "贷方合计"
    end
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :lines, UniboExPoc.Accounting.JournalEntryLine do
      public? true
    end
    belongs_to :created_by, UniboExPoc.Accounting.Party do
      public? true
      source_attribute :created_by_party_id
    end
    belongs_to :journal, UniboExPoc.Accounting.Journal do
      public? true
    end
    belongs_to :partner, UniboExPoc.Accounting.Party do
      public? true
      source_attribute :partner_party_id
    end
    belongs_to :tax_cash_basis_origin, UniboExPoc.Accounting.JournalEntry do
      public? true
    end
    has_many :tax_cash_basis_created_moves, UniboExPoc.Accounting.JournalEntry do
      public? true
      source_attribute :tax_cash_basis_origin_id
      destination_attribute :tax_cash_basis_origin_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:entry_number, :move_type, :entry_date, :invoice_date, :invoice_date_due, :description, :notes, :journal_id, :currency_id, :fiscal_position_id, :invoice_origin, :ref]
      argument :partner_id, :uuid
      argument :lines, {:array, :string}, allow_nil?: false
      change manage_relationship(:lines, :lines, type: :create)
      validate present(:entry_number)
      change relate_actor(:created_by)
      change UniboExPoc.Accounting.Changes.JournalEntry.ComputeTotalDebit
      change UniboExPoc.Accounting.Changes.JournalEntry.ComputeTotalCredit
      change UniboExPoc.Accounting.Changes.JournalEntry.ComputeAmountUntaxed
      change UniboExPoc.Accounting.Changes.JournalEntry.ComputeAmountTax
      change set_attribute(:amount_total, expr((amount_untaxed + amount_tax)))
    end
    update :post do
      description "过账 [R-ACC-001 ~ R-ACC-007]"
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
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change UniboExPoc.Accounting.Changes.JournalEntry.ComputeAmountUntaxed
      change UniboExPoc.Accounting.Changes.JournalEntry.ComputeAmountTax
      change set_attribute(:amount_total, expr((amount_untaxed + amount_tax)))
      change set_attribute(:status, :posted)
      change UniboExPoc.Accounting.Changes.JournalEntry.PostCall8
      require_atomic? false
    end
    update :cancel do
      description "取消（可能生成冲销分录）"
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
      description "重置为草稿"
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

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
