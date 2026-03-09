# Workflow: payment_lifecycle — 付款处理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> post
#   post --> cancel
#   cancel --> reset_to_draft
#   reset_to_draft --> post
# ```
defmodule UniboExPoc.Accounting.Payment do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.Accounting.Payment.Notifier]

  resource do
    description "付款/收款记录。在 Odoo 中通过 _inherits 委托继承 account.move，每个 Payment 即是一个 JournalEntry"
  end

  postgres do
    table "accounting_payments"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_payment

    queries do
      get :get_accounting_payment, :read
      list :list_accounting_payments, :read
    end

    mutations do
      create :create_accounting_payment, :create
      update :post_accounting_payment, :post
      update :cancel_accounting_payment, :cancel
      update :reset_to_draft_accounting_payment, :reset_to_draft
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :payment_number, :string do
      allow_nil? false
      public? true
      description "付款编号"
    end
    attribute :payment_type, :atom do
      allow_nil? false
      constraints one_of: [:inbound, :outbound]
      public? true
      description "收款(inbound) / 付款(outbound)"
    end
    attribute :partner_type, :atom do
      constraints one_of: [:customer, :supplier]
      public? true
      description "客户/供应商"
    end
    attribute :status, :atom do
      constraints one_of: [:draft, :posted, :cancel]
      default :draft
      public? true
      description "付款状态，由底层 move.state 驱动"
    end
    attribute :amount, :decimal do
      allow_nil? false
      public? true
      description "付款金额 [R-PAY-001] 必须 >= 0"
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
      description "付款方式 [R-PAY-002]"
    end
    attribute :destination_account_id, :uuid do
      public? true
      description "应收/应付科目 [R-PAY-003]"
    end
    attribute :reference_number, :string do
      public? true
      description "银行流水号"
    end
    attribute :is_reconciled, :boolean do
      default false
      public? true
      description "计算字段 [R-REC-005]: 对方行 + 差额调整行全部已核销（发票已匹配）
公式: ALL(line.amount_residual == 0) WHERE line IN (counterpart_lines + writeoff_lines)
"
    end
    attribute :is_matched, :boolean do
      default false
      public? true
      description "计算字段 [R-REC-006]: 流动性行全部已核销（银行对账单已匹配）
公式: ALL(line.amount_residual == 0) WHERE line IN (liquidity_lines)
"
    end
    attribute :paired_internal_transfer_payment_id, :uuid do
      public? true
      description "内部调拨配对付款 [R-PAY-005]"
    end
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :journal_entry, UniboExPoc.Accounting.JournalEntry do
      public? true
      allow_nil? false
    end
    has_many :applications, UniboExPoc.Accounting.PaymentApplication do
      public? true
    end
    belongs_to :created_by, UniboExPoc.Accounting.Party do
      public? true
      source_attribute :created_by_party_id
    end
    belongs_to :paired_internal_transfer, UniboExPoc.Accounting.Payment do
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
      # validation: payment_method_belongs_to_journal
      change relate_actor(:created_by)
    end
    update :post do
      description "确认付款（过账底层 move）[R-PAY-003]"
      primary? true
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
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:status, :posted)
      change UniboExPoc.Accounting.Changes.Payment.PostCall3
      change UniboExPoc.Accounting.Changes.Payment.PostCall6
      require_atomic? false
    end
    update :cancel do
      description "取消付款"
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
      description "重置为草稿"
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

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
