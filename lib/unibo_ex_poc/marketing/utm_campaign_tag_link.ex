defmodule UniboV4.Marketing.UtmCampaignTagLink do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "UTM 活动-标签桥接实体"
  end

  postgres do
    table "marketing_utm_campaign_tag_links"
    repo UniboV4.Repo
  end

  graphql do
    type :marketing_utm_campaign_tag_link

    queries do
      get :get_marketing_utm_campaign_tag_link, :read
      list :list_marketing_utm_campaign_tag_links, :read
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :campaign, UniboV4.Marketing.UtmCampaign do
      public? true
      allow_nil? false
      source_attribute :utm_campaign_id
    end
    belongs_to :tag, UniboV4.Marketing.UtmTag do
      public? true
      allow_nil? false
      source_attribute :utm_tag_id
    end
  end

  actions do
    defaults [:read, :update]
  end

end
