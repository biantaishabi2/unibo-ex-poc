defmodule UniboV4.Ofbiz.Marketing.MarketingCampaign do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "marketing_campaigns"
    repo UniboV4.Repo
  end

  graphql do
    type :marketing_marketing_campaign

    queries do
      get :get_marketing_marketing_campaign, :read
      list :list_marketing_marketing_campaigns, :read
    end

    mutations do
      create :create_marketing_marketing_campaign, :create
      update :update_marketing_marketing_campaign, :update
      destroy :delete_marketing_marketing_campaign, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :marketing_campaign_id, :string, public?: true
    attribute :status_id, :string, public?: true
    attribute :campaign_name, :string, public?: true
    attribute :campaign_summary, :string, public?: true
    attribute :budgeted_cost, :decimal do
      public? true
      description "预算成本"
    end
    attribute :actual_cost, :decimal, public?: true
    attribute :estimated_cost, :decimal, public?: true
    attribute :currency_uom_id, :string, public?: true
    attribute :from_date, :utc_datetime, public?: true
    attribute :thru_date, :utc_datetime, public?: true
    attribute :is_active, :boolean, public?: true
    attribute :converted_leads, :string, public?: true
    attribute :expected_response_percent, :float, public?: true
    attribute :expected_revenue, :decimal, public?: true
    attribute :num_sent, :integer, public?: true
    attribute :start_date, :utc_datetime, public?: true
    attribute :created_by_user_login, :string, public?: true
    attribute :last_modified_by_user_login, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :parent_marketing_campaign, UniboV4.Ofbiz.Marketing.MarketingCampaign do
      public? true
      source_attribute :parent_campaign_id
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
