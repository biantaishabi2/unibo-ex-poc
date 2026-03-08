defmodule UniboExPoc.Ofbiz.Marketing.SalesOpportunityQuote do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "marketing_sales_opportunity_quotes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :marketing_sales_opportunity_quote

    queries do
      get :get_marketing_sales_opportunity_quote, :read
      list :list_marketing_sales_opportunity_quotes, :read
    end

    mutations do
      create :create_marketing_sales_opportunity_quote, :create
      update :update_marketing_sales_opportunity_quote, :update
      destroy :delete_marketing_sales_opportunity_quote, :destroy
    end

  end

  attributes do
    attribute :quote_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :sales_opportunity, UniboExPoc.Ofbiz.Marketing.SalesOpportunity do
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
