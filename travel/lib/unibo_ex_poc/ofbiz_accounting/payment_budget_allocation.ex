defmodule UniboExPoc.Ofbiz.Accounting.PaymentBudgetAllocation do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_payment_budget_allocations"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_payment_budget_allocation

    queries do
      get :get_accounting_payment_budget_allocation, :read
      list :list_accounting_payment_budget_allocations, :read
    end

    mutations do
      create :create_accounting_payment_budget_allocation, :create
      update :update_accounting_payment_budget_allocation, :update
      destroy :delete_accounting_payment_budget_allocation, :destroy
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
    attribute :payment_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :amount, :decimal, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :budget, UniboExPoc.Ofbiz.Accounting.Budget do
      public? true
      define_attribute? false
    end
    belongs_to :payment, UniboExPoc.Ofbiz.Accounting.Payment do
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
