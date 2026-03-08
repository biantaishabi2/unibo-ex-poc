defmodule UniboV4.Ofbiz.Marketing.MarketingCampaignNote do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "marketing_campaign_notes"
    repo UniboV4.Repo
  end

  graphql do
    type :marketing_marketing_campaign_note

    queries do
      get :get_marketing_marketing_campaign_note, :read
      list :list_marketing_marketing_campaign_notes, :read
    end

    mutations do
      create :create_marketing_marketing_campaign_note, :create
      update :update_marketing_marketing_campaign_note, :update
      destroy :delete_marketing_marketing_campaign_note, :destroy
    end

  end

  attributes do
    attribute :note_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
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

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
