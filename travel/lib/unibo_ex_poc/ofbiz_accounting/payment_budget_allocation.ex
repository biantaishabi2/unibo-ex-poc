defmodule UniboExPoc.Ofbiz.Accounting.PaymentBudgetAllocation do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

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
    attribute :budget_item_seq_id, :string do
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
    end
    belongs_to :payment, UniboExPoc.Ofbiz.Accounting.Payment do
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
