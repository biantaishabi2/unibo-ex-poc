defmodule UniboV4.Ofbiz.Marketing.SalesOpportunityWorkEffort do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "marketing_sales_opportunity_work_efforts"
    repo UniboV4.Repo
  end

  graphql do
    type :marketing_sales_opportunity_work_effort

    queries do
      get :get_marketing_sales_opportunity_work_effort, :read
      list :list_marketing_sales_opportunity_work_efforts, :read
    end

    mutations do
      create :create_marketing_sales_opportunity_work_effort, :create
      update :update_marketing_sales_opportunity_work_effort, :update
      destroy :delete_marketing_sales_opportunity_work_effort, :destroy
    end

  end

  attributes do
    attribute :work_effort_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :sales_opportunity, UniboV4.Ofbiz.Marketing.SalesOpportunity do
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
