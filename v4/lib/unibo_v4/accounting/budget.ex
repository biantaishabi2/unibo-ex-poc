defmodule UniboV4.Accounting.Budget do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Accounting.Budget.Notifier]

  postgres do
    table "budgets"
    repo UniboV4.Repo
  end

  graphql do
    type :budget

    queries do
      get :get_budget, :read
      list :list_budgets, :read
    end

    mutations do
      create :create_budget, :create
      update :submit_budget, :submit
      update :approve_budget, :approve
      update :reject_budget, :reject
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :budget_number, :string, allow_nil?: false
    attribute :name, :string, allow_nil?: false
    attribute :status, :atom do
      constraints one_of: [:draft, :submitted, :approved, :rejected]
      default :draft
    end
    attribute :fiscal_year, :integer, allow_nil?: false
    attribute :total_amount, :decimal
    attribute :description, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :items, UniboV4.Accounting.BudgetItem
    belongs_to :created_by, UniboV4.Accounts.User
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
      # TODO: 跨实体聚合表达式暂不支持
    end
    update :submit do
      accept []
      argument :items, {:array, :map}, default: []
      change manage_relationship(:items, :items, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_equals(:status, :draft) do
        message "只有草稿状态可以提交"
      end
      change set_attribute(:status, :submitted)
    end
    update :approve do
      accept []
      argument :items, {:array, :map}, default: []
      change manage_relationship(:items, :items, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_equals(:status, :submitted) do
        message "只有已提交状态可以审批"
      end
      change set_attribute(:status, :approved)
    end
    update :reject do
      argument :reason, :string, allow_nil?: false
      argument :items, {:array, :map}, default: []
      change manage_relationship(:items, :items, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_equals(:status, :submitted) do
        message "只有已提交状态可以驳回"
      end
      change set_attribute(:status, :rejected)
    end
  end

  identities do
    identity :unique_budget_number, [:budget_number]
  end

end
