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
defmodule UniboV4.Accounting.Budget do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Accounting.Budget.Notifier]

  postgres do
    table "accounting_budgets"
    repo UniboV4.Repo
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
    end
    attribute :total_amount, :decimal, public?: true
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :items, UniboV4.Accounting.BudgetItem do
      public? true
    end
    belongs_to :created_by, UniboV4.Accounting.User do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:budget_number, :name, :fiscal_year, :description]
      argument :items, {:array, :map}, allow_nil?: false
      change manage_relationship(:items, :items, type: :create)
      validate present(:budget_number)
      validate present(:name)
      change relate_actor(:created_by)
      # TODO: 跨实体聚合表达式暂不支持
    end
    update :submit do
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

end
