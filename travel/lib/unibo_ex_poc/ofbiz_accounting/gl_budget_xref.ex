defmodule UniboExPoc.Ofbiz.Accounting.GlBudgetXref do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_gl_budget_xrefs"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_gl_budget_xref

    queries do
      get :get_accounting_gl_budget_xref, :read
      list :list_accounting_gl_budget_xrefs, :read
    end

    mutations do
      create :create_accounting_gl_budget_xref, :create
      update :update_accounting_gl_budget_xref, :update
      destroy :delete_accounting_gl_budget_xref, :destroy
    end

  end

  attributes do
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :allocation_percentage, :decimal, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :gl_account, UniboExPoc.Ofbiz.Accounting.GlAccount do
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
