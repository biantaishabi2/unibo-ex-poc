# Workflow: expense_category_maintain_flow — 费用类别维护流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.Expenses.ExpenseCategory do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Expenses,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "费用类别"
  end

  postgres do
    table "expenses_expense_categories"
    repo UniboExPoc.Repo
  end

  graphql do
    type :expenses_expense_category

    queries do
      get :get_expenses_expense_category, :read
      list :list_expenses_expense_categorys, :read
    end

    mutations do
      create :create_expenses_expense_category, :create
      update :update_expenses_expense_category, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "类别名称"
    end
    attribute :code, :string do
      allow_nil? false
      public? true
      description "类别编号"
    end
    attribute :description, :string, public?: true
    attribute :is_active, :boolean do
      default true
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :account, UniboExPoc.Expenses.Account do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :code, :description]
      argument :account_id, :uuid
      validate present(:name)
      validate present(:code)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :description, :is_active]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_category_code, [:code]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
