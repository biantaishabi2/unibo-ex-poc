defmodule UniboExPoc.Ofbiz.Accounting.BudgetRevisionImpact do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_budget_revision_impacts"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_budget_revision_impact

    queries do
      get :get_accounting_budget_revision_impact, :read
      list :list_accounting_budget_revision_impacts, :read
    end

    mutations do
      create :create_accounting_budget_revision_impact, :create
      update :update_accounting_budget_revision_impact, :update
      destroy :delete_accounting_budget_revision_impact, :destroy
    end

  end

  attributes do
    attribute :budget_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :budget_item_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :revision_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :revised_amount, :decimal, public?: true
    attribute :add_delete_flag, :boolean, public?: true
    attribute :revision_reason, :string, public?: true
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
