defmodule UniboExPoc.Ofbiz.Accounting.BudgetScenarioRule do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_budget_scenario_rules"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_budget_scenario_rule

    queries do
      get :get_accounting_budget_scenario_rule, :read
      list :list_accounting_budget_scenario_rules, :read
    end

    mutations do
      create :create_accounting_budget_scenario_rule, :create
      update :update_accounting_budget_scenario_rule, :update
      destroy :delete_accounting_budget_scenario_rule, :destroy
    end

  end

  attributes do
    attribute :budget_scenario_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :budget_item_type_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :amount_change, :decimal, public?: true
    attribute :percentage_change, :decimal, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :budget_scenario, UniboExPoc.Ofbiz.Accounting.BudgetScenario do
      public? true
      define_attribute? false
    end
    belongs_to :budget_item_type, UniboExPoc.Ofbiz.Accounting.BudgetItemType do
      public? true
      define_attribute? false
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
