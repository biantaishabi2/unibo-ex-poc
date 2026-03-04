defmodule UniboV4.Marketing.UtmCampaignTagLink do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "marketing_utm_campaign_tag_links"
    repo UniboV4.Repo
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
    defaults [:read]
  end

end
