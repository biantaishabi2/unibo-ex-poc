defmodule UniboExPoc.Ofbiz.Accounting.BudgetStatus do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_budget_statuses"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_budget_status

    queries do
      get :get_accounting_budget_status, :read
      list :list_accounting_budget_statuss, :read
    end

    mutations do
      create :create_accounting_budget_status, :create
      update :update_accounting_budget_status, :update
      destroy :delete_accounting_budget_status, :destroy
    end

  end

  attributes do
    attribute :status_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :status_date, :utc_datetime, public?: true
    attribute :comments, :string, public?: true
    attribute :change_by_user_login_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :budget, UniboExPoc.Ofbiz.Accounting.Budget do
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
