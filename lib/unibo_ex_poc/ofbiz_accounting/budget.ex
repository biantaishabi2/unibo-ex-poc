defmodule UniboExPoc.Ofbiz.Accounting.Budget do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

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
      update :update_accounting_budget, :update
      destroy :delete_accounting_budget, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :budget_id, :string, public?: true
    attribute :custom_time_period_id, :string, public?: true
    attribute :comments, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :budget_type, UniboExPoc.Ofbiz.Accounting.BudgetType do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
