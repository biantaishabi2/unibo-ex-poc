# Workflow: expense_report_approval_payment_flow — 报销单提交审批并过账付款流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   submit --> [*]
#   approve --> [*]
#   post --> [*]
#   register_payment --> [*]
# ```
# Workflow: expense_report_refuse_reset_flow — 报销单驳回后重置再提交流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   submit --> [*]
#   refuse --> [*]
#   reset --> [*]
#   submit --> [*]
#   approve --> [*]
# ```
defmodule UniboExPoc.Expenses.ExpenseReport do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Expenses,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.Expenses.ExpenseReport.Notifier]

  resource do
    description "费用报告（员工报销发票）"
  end

  postgres do
    table "expenses_expense_reports"
    repo UniboExPoc.Repo
  end

  graphql do
    type :expenses_expense_report

    queries do
      get :get_expenses_expense_report, :read
      list :list_expenses_expense_reports, :read
    end

    mutations do
      create :create_expenses_expense_report, :create
      update :submit_expenses_expense_report, :submit
      update :approve_expenses_expense_report, :approve
      update :refuse_expenses_expense_report, :refuse
      update :post_expenses_expense_report, :post
      update :register_payment_expenses_expense_report, :register_payment
      update :reset_expenses_expense_report, :reset
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :report_number, :string do
      allow_nil? false
      public? true
      description "报销单号"
    end
    attribute :state, :atom do
      constraints one_of: [:draft, :submitted, :approved, :posted, :done, :cancelled]
      default :draft
      public? true
      description "报销单状态（由多字段计算得出）"
    end
    attribute :approval_state, :atom do
      constraints one_of: [:submitted, :approved, :cancelled]
      public? true
      description "审批状态（内部字段，驱动 state 计算）"
    end
    attribute :payment_mode, :atom do
      allow_nil? false
      constraints one_of: [:own_account, :company_account]
      public? true
      description "支付方式（员工垫付 / 公司支付）"
    end
    attribute :total_amount, :decimal do
      public? true
      description "报销总金额"
    end
    attribute :total_tax_amount, :decimal do
      public? true
      description "税额合计"
    end
    attribute :untaxed_amount, :decimal do
      public? true
      description "不含税金额"
    end
    attribute :amount_residual, :decimal do
      public? true
      description "待付余额"
    end
    attribute :report_date, :date do
      allow_nil? false
      public? true
    end
    attribute :approval_date, :utc_datetime do
      public? true
      description "审批日期"
    end
    attribute :description, :string, public?: true
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :employee, UniboExPoc.Expenses.Employee do
      public? true
      allow_nil? false
    end
    belongs_to :approver, UniboExPoc.Expenses.Party do
      public? true
      source_attribute :approver_party_id
    end
    belongs_to :currency, UniboExPoc.Expenses.Currency do
      public? true
      allow_nil? false
    end
    belongs_to :company, UniboExPoc.Expenses.Party do
      public? true
      allow_nil? false
      source_attribute :company_party_id
    end
    belongs_to :employee_journal, UniboExPoc.Expenses.Journal do
      public? true
    end
    belongs_to :payment_method_line, UniboExPoc.Expenses.PaymentMethodLine do
      public? true
    end
    has_many :expense_line_ids, UniboExPoc.Expenses.ExpenseLine do
      public? true
      destination_attribute :report_id
    end
    has_many :account_move_ids, UniboExPoc.Expenses.AccountMove do
      public? true
      destination_attribute :expense_report_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:report_number, :report_date, :payment_mode, :description, :notes]
      argument :lines, {:array, :string}, allow_nil?: false
      argument :employee_id, :uuid, allow_nil?: false
      argument :currency_id, :uuid, allow_nil?: false
      argument :company_id, :uuid, allow_nil?: false
      change manage_relationship(:employee_id, :employee, type: :append, on_lookup: :relate)
      change manage_relationship(:currency_id, :currency, type: :append, on_lookup: :relate)
      change manage_relationship(:company_id, :company, type: :append, on_lookup: :relate)
      argument :expense_line_ids, {:array, :map}, default: []
      change manage_relationship(:expense_line_ids, :expense_line_ids, type: :create)
      validate present(:report_number)
      # WARNING: compare :expense_line_ids_payment_mode 缺少 params，校验定义不完整
      # WARNING: compare :expense_line_ids_employee_id 缺少 params，校验定义不完整
      # WARNING: compare :expense_line_ids_company_id 缺少 params，校验定义不完整
      change relate_actor(:employee)
      change UniboExPoc.Expenses.Changes.ExpenseReport.ComputeTotalAmount
      change set_attribute(:id, expr(id))
      change UniboExPoc.Expenses.Integrations.ExpenseReport.CreatePricingFetchStandardPriceBridge
    end
    update :submit do
      description "提交审批（draft → submitted）"
      primary? true
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以提交"
      # skipped: validate not_empty :expense_line_ids (incompatible with bulk update atomic path)
      # skipped: validate all_present :expense_line_ids_product_id (incompatible with bulk update atomic path)
      # skipped: validate compare :expense_line_ids_employee_id (incompatible with bulk update atomic path)
      # skipped: validate all_match :expense_line_ids_total_amount (incompatible with bulk update atomic path)
      # skipped: validate compare :expense_line_ids_payment_mode (incompatible with bulk update atomic path)
      # skipped: validate compare :expense_line_ids_employee_id (incompatible with bulk update atomic path)
      # skipped: validate compare :expense_line_ids_company_id (incompatible with bulk update atomic path)
      change set_attribute(:approval_state, :submitted)
      change set_attribute(:id, expr(id))
      change UniboExPoc.Expenses.Integrations.ExpenseReport.SubmitSubmitScheduleActivityBridge
      change UniboExPoc.Expenses.Integrations.ExpenseReport.SubmitPricingFetchStandardPriceBridge
      change UniboExPoc.Expenses.Integrations.ExpenseReport.SubmitTaxComputeCallAccountTaxBridge
      require_atomic? false
    end
    update :approve do
      description "审批通过（submitted → approved）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :submitted do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :submitted}))
        end
      end
      # message: "只有已提交状态可以审批"
      # skipped: validate authorize : (incompatible with bulk update atomic path)
      # skipped: validate duplicate_check : (incompatible with bulk update atomic path)
      # skipped: validate valid_distribution :expense_line_ids_analytic_distribution (incompatible with bulk update atomic path)
      change set_attribute(:approval_state, :approved)
      change set_attribute(:approver_id, %{op: "ref", args: ["current_user"]})
      change set_attribute(:approval_date, %{op: "func", args: ["now"]})
      change set_attribute(:id, expr(id))
      change UniboExPoc.Expenses.Integrations.ExpenseReport.ApproveApproveRefuseSendMailBridge
      require_atomic? false
    end
    update :refuse do
      description "审批驳回（submitted/approved → cancelled）"
      argument :reason, :string, allow_nil?: false
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current in [:submitted, :approved] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must be one of %{values}", vars: %{values: [:submitted, :approved]}))
        end
      end
      # message: "只有已提交或已审批状态可以驳回"
      # skipped: validate present :reason (incompatible with bulk update atomic path)
      # skipped: validate empty :account_move_ids (incompatible with bulk update atomic path)
      change set_attribute(:approval_state, :cancelled)
      change set_attribute(:id, expr(id))
      change UniboExPoc.Expenses.Integrations.ExpenseReport.RefuseApproveRefuseSendMailBridge
      require_atomic? false
    end
    update :post do
      description "过账（approved → posted，创建会计凭证或付款）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :approved do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :approved}))
        end
      end
      # message: "只有已审批状态可以过账"
      # skipped: validate present :employee_work_email (incompatible with bulk update atomic path)
      # skipped: validate present :employee_journal_id (incompatible with bulk update atomic path)
      change set_attribute(:id, expr(id))
      change UniboExPoc.Expenses.Integrations.ExpenseReport.PostPostOwnAccountRegisterPaymentBridge
      change UniboExPoc.Expenses.Integrations.ExpenseReport.PostPostCompanyAccountCreatePaymentBridge
      change UniboExPoc.Expenses.Integrations.ExpenseReport.PostTaxComputeCallAccountTaxBridge
      require_atomic? false
    end
    update :register_payment do
      description "登记付款（posted → done，仅 own_account 模式）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :posted do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :posted}))
        end
      end
      # message: "只有已过账状态可以登记付款"
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :payment_mode)
        if current == :own_account do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :payment_mode, message: "must equal %{value}", vars: %{value: :own_account}))
        end
      end
      # message: "仅员工垫付模式需要登记付款 (规则20)"
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :reset do
      description "重置（任意状态 → draft，已过账凭证先冲销）"
      accept []
      change set_attribute(:id, expr(id))
      change UniboExPoc.Expenses.Integrations.ExpenseReport.ResetResetReverseMovesBridge
      require_atomic? false
    end
  end

  validations do
    # prevent_destroy: 在 destroy action 中通过 change 拒绝操作
  end

  identities do
    identity :unique_report_number, [:report_number]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
