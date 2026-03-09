defmodule UniboExPoc.Ofbiz.Marketing.TrackingCode do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "marketing_tracking_codes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :marketing_tracking_code

    queries do
      get :get_marketing_tracking_code, :read
      list :list_marketing_tracking_codes, :read
    end

    mutations do
      create :create_marketing_tracking_code, :create
      update :update_marketing_tracking_code, :update
      destroy :delete_marketing_tracking_code, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :tracking_code_id, :string, public?: true
    attribute :redirect_url, :string, public?: true
    attribute :override_logo, :string, public?: true
    attribute :override_css, :string, public?: true
    attribute :prod_catalog_id, :string, public?: true
    attribute :comments, :string, public?: true
    attribute :description, :string, public?: true
    attribute :trackable_lifetime, :integer, public?: true
    attribute :billable_lifetime, :integer, public?: true
    attribute :from_date, :utc_datetime, public?: true
    attribute :thru_date, :utc_datetime, public?: true
    attribute :group_id, :string, public?: true
    attribute :subgroup_id, :string, public?: true
    attribute :created_date, :utc_datetime, public?: true
    attribute :created_by_user_login, :string, public?: true
    attribute :last_modified_date, :utc_datetime, public?: true
    attribute :last_modified_by_user_login, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :marketing_campaign, UniboExPoc.Ofbiz.Marketing.MarketingCampaign do
      public? true
    end
    belongs_to :tracking_code_type, UniboExPoc.Ofbiz.Marketing.TrackingCodeType do
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
