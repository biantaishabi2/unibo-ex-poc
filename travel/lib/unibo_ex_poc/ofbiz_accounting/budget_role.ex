defmodule UniboExPoc.Ofbiz.Accounting.BudgetRole do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_budget_roles"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_budget_role

    queries do
      get :get_accounting_budget_role, :read
      list :list_accounting_budget_roles, :read
    end

    mutations do
      create :create_accounting_budget_role, :create
      update :update_accounting_budget_role, :update
      destroy :delete_accounting_budget_role, :destroy
    end

  end

  attributes do
    attribute :budget_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :party_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :role_type_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :budget, UniboExPoc.Ofbiz.Accounting.Budget do
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
