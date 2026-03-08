defmodule UniboV4.Ofbiz.Accounting.BudgetAttribute do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_budget_attributes"
    repo UniboV4.Repo
  end

  graphql do
    type :accounting_budget_attribute

    queries do
      get :get_accounting_budget_attribute, :read
      list :list_accounting_budget_attributes, :read
    end

    mutations do
      create :create_accounting_budget_attribute, :create
      update :update_accounting_budget_attribute, :update
      destroy :delete_accounting_budget_attribute, :destroy
    end

  end

  attributes do
    attribute :attr_name, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :attr_value, :string, public?: true
    attribute :attr_description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
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
