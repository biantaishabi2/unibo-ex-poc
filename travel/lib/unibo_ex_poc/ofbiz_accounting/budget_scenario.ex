defmodule UniboExPoc.Ofbiz.Accounting.BudgetScenario do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_budget_scenarios"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_budget_scenario

    queries do
      get :get_accounting_budget_scenario, :read
      list :list_accounting_budget_scenarios, :read
    end

    mutations do
      create :create_accounting_budget_scenario, :create
      update :update_accounting_budget_scenario, :update
      destroy :delete_accounting_budget_scenario, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :budget_scenario_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
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
