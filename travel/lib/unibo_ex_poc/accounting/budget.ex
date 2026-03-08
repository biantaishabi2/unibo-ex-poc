# Workflow: budget_approval — 预算审批流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> submit
#   submit --> approve
#   submit --> reject
#   approve --> [*] : approved
#   reject --> [*]
# ```
defmodule UniboExPoc.Accounting.Budget do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.Accounting.Budget.Notifier]

  resource do
    description "预算"
  end

  postgres do
    table "accounting_budgets"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_budget

    queries do
      get :get_accounting_budget, :read
      list :list_accounting_budgets, :read
    end

    mutations do
      create :create_accounting_budget, :create
      update :submit_accounting_budget, :submit
      update :approve_accounting_budget, :approve
      update :reject_accounting_budget, :reject
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :budget_number, :string do
      allow_nil? false
      public? true
      description "预算编号"
    end
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :status, :atom do
      constraints one_of: [:draft, :submitted, :approved, :rejected]
      default :draft
      public? true
    end
    attribute :fiscal_year, :integer do
      allow_nil? false
      public? true
      description "财年"
    end
    attribute :total_amount, :decimal do
      public? true
      description "预算总金额"
    end
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :items, UniboExPoc.Accounting.BudgetItem do
      public? true
    end
    belongs_to :created_by, UniboExPoc.Accounting.Party do
      public? true
      source_attribute :created_by_party_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:budget_number, :name, :fiscal_year, :description]
      argument :items, {:array, :string}, allow_nil?: false
      change manage_relationship(:items, :items, type: :create)
      validate present(:budget_number)
      validate present(:name)
      change relate_actor(:created_by)
      change UniboExPoc.Accounting.Changes.Budget.ComputeTotalAmount
    end
    update :submit do
      description "提交审批"
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
      # message: "只有草稿状态可以提交"
      change set_attribute(:status, :submitted)
      require_atomic? false
    end
    update :approve do
      description "审批通过"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :submitted do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :submitted}))
        end
      end
      # message: "只有已提交状态可以审批"
      change set_attribute(:status, :approved)
      require_atomic? false
    end
    update :reject do
      description "审批驳回"
      argument :reason, :string, allow_nil?: false
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :submitted do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :submitted}))
        end
      end
      # message: "只有已提交状态可以驳回"
      change set_attribute(:status, :rejected)
      require_atomic? false
    end
  end

  identities do
    identity :unique_budget_number, [:budget_number]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
