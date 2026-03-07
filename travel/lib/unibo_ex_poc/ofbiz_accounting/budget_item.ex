defmodule UniboExPoc.Ofbiz.Accounting.BudgetItem do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_budget_items"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_budget_item

    queries do
      get :get_accounting_budget_item, :read
      list :list_accounting_budget_items, :read
    end

    mutations do
      create :create_accounting_budget_item, :create
      update :update_accounting_budget_item, :update
      destroy :delete_accounting_budget_item, :destroy
    end

  end

  attributes do
    attribute :budget_item_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :amount, :decimal, public?: true
    attribute :purpose, :string, public?: true
    attribute :justification, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :budget, UniboExPoc.Ofbiz.Accounting.Budget do
      public? true
    end
    belongs_to :budget_item_type, UniboExPoc.Ofbiz.Accounting.BudgetItemType do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
