defmodule UniboExPoc.Ofbiz.Marketing.MarketingCampaignPrice do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "marketing_campaign_prices"
    repo UniboExPoc.Repo
  end

  graphql do
    type :marketing_marketing_campaign_price

    queries do
      get :get_marketing_marketing_campaign_price, :read
      list :list_marketing_marketing_campaign_prices, :read
    end

    mutations do
      create :create_marketing_marketing_campaign_price, :create
      update :update_marketing_marketing_campaign_price, :update
      destroy :delete_marketing_marketing_campaign_price, :destroy
    end

  end

  attributes do
    attribute :product_price_rule_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :marketing_campaign, UniboExPoc.Ofbiz.Marketing.MarketingCampaign do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
