defmodule UniboV4.Ofbiz.Marketing.MarketingCampaignRole do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "marketing_campaign_roles"
    repo UniboV4.Repo
  end

  graphql do
    type :marketing_marketing_campaign_role

    queries do
      get :get_marketing_marketing_campaign_role, :read
      list :list_marketing_marketing_campaign_roles, :read
    end

    mutations do
      create :create_marketing_marketing_campaign_role, :create
      update :update_marketing_marketing_campaign_role, :update
      destroy :delete_marketing_marketing_campaign_role, :destroy
    end

  end

  attributes do
    attribute :party_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :role_type_id, :string do
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
    belongs_to :marketing_campaign, UniboV4.Ofbiz.Marketing.MarketingCampaign do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
