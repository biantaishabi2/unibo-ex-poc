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
defmodule UniboV4.Expenses.ExpenseReport do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Expenses,
    data_layer: AshPostgres.DataLayer,
    notifiers: [UniboV4.Expenses.ExpenseReport.Notifier]

  postgres do
    table "expenses_expense_reports"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :report_number, :string do
      allow_nil? false
      public? true
    end
    attribute :state, :atom do
      constraints one_of: [:draft, :submitted, :approved, :posted, :done, :cancelled]
      default :draft
      public? true
    end
    attribute :approval_state, :atom do
      constraints one_of: [:submitted, :approved, :cancelled]
      public? true
    end
    attribute :payment_mode, :atom do
      allow_nil? false
      constraints one_of: [:own_account, :company_account]
      public? true
    end
    attribute :total_amount, :decimal, public?: true
    attribute :total_tax_amount, :decimal, public?: true
    attribute :untaxed_amount, :decimal, public?: true
    attribute :amount_residual, :decimal, public?: true
    attribute :report_date, :date do
      allow_nil? false
      public? true
    end
    attribute :approval_date, :utc_datetime, public?: true
    attribute :description, :string, public?: true
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :employee, UniboV4.Expenses.Employee do
      public? true
      allow_nil? false
    end
    belongs_to :approver, UniboV4.Expenses.User do
      public? true
    end
    belongs_to :currency, UniboV4.Expenses.Currency do
      public? true
      allow_nil? false
    end
    belongs_to :company, UniboV4.Expenses.Company do
      public? true
      allow_nil? false
    end
    belongs_to :employee_journal, UniboV4.Expenses.Journal do
      public? true
    end
    belongs_to :payment_method_line, UniboV4.Expenses.PaymentMethodLine do
      public? true
    end
    has_many :expense_line_ids, UniboV4.Expenses.ExpenseLine do
      public? true
      destination_attribute :report_id
    end
    has_many :account_move_ids, UniboV4.Expenses.AccountMove do
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
      # TODO: 不支持的 action 内校验规则 all_equal
      # TODO: 不支持的 action 内校验规则 all_equal
      # TODO: 不支持的 action 内校验规则 all_equal
      change relate_actor(:employee)
      # TODO: 跨实体聚合表达式暂不支持
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :submit do
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
      # skipped: validate all_equal :expense_line_ids_employee_id (incompatible with bulk update atomic path)
      # skipped: validate all_match :expense_line_ids_total_amount (incompatible with bulk update atomic path)
      # skipped: validate all_equal :expense_line_ids_payment_mode (incompatible with bulk update atomic path)
      # skipped: validate all_equal :expense_line_ids_employee_id (incompatible with bulk update atomic path)
      # skipped: validate all_equal :expense_line_ids_company_id (incompatible with bulk update atomic path)
      change set_attribute(:approval_state, :submitted)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :approve do
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
      # TODO: set_attribute :approver_id 需要复杂表达式
      # TODO: set_attribute :approval_date 需要复杂表达式
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :refuse do
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
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :post do
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
      # skipped: validate present(:employee_journal_id) — field not found
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :register_payment do
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
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :reset do
      accept []
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
  end

  validations do
    # TODO: 不支持的校验规则 prevent_delete
  end

  identities do
    identity :unique_report_number, [:report_number]
  end

end
