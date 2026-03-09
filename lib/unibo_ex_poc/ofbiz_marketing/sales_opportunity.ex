defmodule UniboExPoc.Ofbiz.Marketing.SalesOpportunity do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "marketing_sales_opportunities"
    repo UniboExPoc.Repo
  end

  graphql do
    type :marketing_sales_opportunity

    queries do
      get :get_marketing_sales_opportunity, :read
      list :list_marketing_sales_opportunitys, :read
    end

    mutations do
      create :create_marketing_sales_opportunity, :create
      update :update_marketing_sales_opportunity, :update
      destroy :delete_marketing_sales_opportunity, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :sales_opportunity_id, :string, public?: true
    attribute :opportunity_name, :string, public?: true
    attribute :description, :string, public?: true
    attribute :next_step, :string, public?: true
    attribute :next_step_date, :utc_datetime, public?: true
    attribute :estimated_amount, :decimal, public?: true
    attribute :estimated_probability, :decimal, public?: true
    attribute :currency_uom_id, :string, public?: true
    attribute :data_source_id, :string, public?: true
    attribute :estimated_close_date, :utc_datetime, public?: true
    attribute :type_enum_id, :string, public?: true
    attribute :created_by_user_login, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :sales_opportunity_stage, UniboExPoc.Ofbiz.Marketing.SalesOpportunityStage do
      public? true
      source_attribute :opportunity_stage_id
    end
    belongs_to :marketing_campaign, UniboExPoc.Ofbiz.Marketing.MarketingCampaign do
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
