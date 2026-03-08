defmodule UniboV4.Ofbiz.Accounting.BudgetScenarioApplication do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_budget_scenario_applications"
    repo UniboV4.Repo
  end

  graphql do
    type :accounting_budget_scenario_application

    queries do
      get :get_accounting_budget_scenario_application, :read
      list :list_accounting_budget_scenario_applications, :read
    end

    mutations do
      create :create_accounting_budget_scenario_application, :create
      update :update_accounting_budget_scenario_application, :update
      destroy :delete_accounting_budget_scenario_application, :destroy
    end

  end

  attributes do
    attribute :budget_scenario_applic_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :budget_item_seq_id, :string, public?: true
    attribute :amount_change, :decimal, public?: true
    attribute :percentage_change, :decimal, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :budget_scenario, UniboV4.Ofbiz.Accounting.BudgetScenario do
      public? true
    end
    belongs_to :budget, UniboV4.Ofbiz.Accounting.Budget do
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
