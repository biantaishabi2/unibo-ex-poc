defmodule UniboV4.Expenses.ExpenseReport do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Expenses,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Expenses.ExpenseReport.Notifier]

  postgres do
    table "expense_reports"
    repo UniboV4.Repo
  end

  graphql do
    type :expense_report

    queries do
      get :get_expense_report, :read
      list :list_expense_reports, :read
    end

    mutations do
      create :create_expense_report, :create
      update :submit_expense_report, :submit
      update :approve_expense_report, :approve
      update :reject_expense_report, :reject
      update :mark_paid_expense_report, :mark_paid
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :report_number, :string, allow_nil?: false
    attribute :status, :atom do
      constraints one_of: [:draft, :submitted, :approved, :rejected, :paid]
      default :draft
    end
    attribute :total_amount, :decimal
    attribute :currency, :string, default: "CNY"
    attribute :report_date, :date, allow_nil?: false
    attribute :description, :string
    attribute :notes, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :lines, UniboV4.Expenses.ExpenseLine
    belongs_to :submitted_by, UniboV4.Accounts.User
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:report_number, :report_date, :currency, :description, :notes]
      argument :lines, {:array, :string}, allow_nil?: false
      change manage_relationship(:lines, :lines, type: :create)
      validate present(:report_number)
      change relate_actor(:submitted_by)
      # TODO: 跨实体聚合表达式暂不支持
    end
    update :submit do
      accept []
      argument :lines, {:array, :map}, default: []
      change manage_relationship(:lines, :lines, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_equals(:status, :draft) do
        message "只有草稿状态可以提交"
      end
      change set_attribute(:status, :submitted)
    end
    update :approve do
      accept []
      argument :lines, {:array, :map}, default: []
      change manage_relationship(:lines, :lines, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_equals(:status, :submitted) do
        message "只有已提交状态可以审批"
      end
      change set_attribute(:status, :approved)
    end
    update :reject do
      argument :reason, :string, allow_nil?: false
      argument :lines, {:array, :map}, default: []
      change manage_relationship(:lines, :lines, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_equals(:status, :submitted) do
        message "只有已提交状态可以驳回"
      end
      change set_attribute(:status, :rejected)
    end
    update :mark_paid do
      accept []
      argument :lines, {:array, :map}, default: []
      change manage_relationship(:lines, :lines, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_equals(:status, :approved) do
        message "只有已审批状态可以标记付款"
      end
      change set_attribute(:status, :paid)
    end
  end

  identities do
    identity :unique_report_number, [:report_number]
  end

end
