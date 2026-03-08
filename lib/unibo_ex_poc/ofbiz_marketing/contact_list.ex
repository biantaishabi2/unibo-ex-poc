defmodule UniboV4.Ofbiz.Marketing.ContactList do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "marketing_contact_lists"
    repo UniboV4.Repo
  end

  graphql do
    type :marketing_contact_list

    queries do
      get :get_marketing_contact_list, :read
      list :list_marketing_contact_lists, :read
    end

    mutations do
      create :create_marketing_contact_list, :create
      update :update_marketing_contact_list, :update
      destroy :delete_marketing_contact_list, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :contact_list_id, :string, public?: true
    attribute :contact_mech_type_id, :string, public?: true
    attribute :contact_list_name, :string, public?: true
    attribute :description, :string, public?: true
    attribute :comments, :string, public?: true
    attribute :is_public, :boolean, public?: true
    attribute :single_use, :boolean do
      public? true
      description "列表成员是否应仅被联系一次"
    end
    attribute :owner_party_id, :string, public?: true
    attribute :verify_email_from, :string, public?: true
    attribute :verify_email_screen, :string do
      public? true
      description "验证邮箱屏幕"
    end
    attribute :verify_email_subject, :string, public?: true
    attribute :verify_email_web_site_id, :string, public?: true
    attribute :opt_out_screen, :string, public?: true
    attribute :created_by_user_login, :string, public?: true
    attribute :last_modified_by_user_login, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :marketing_campaign, UniboV4.Ofbiz.Marketing.MarketingCampaign do
      public? true
    end
    belongs_to :contact_list_type, UniboV4.Ofbiz.Marketing.ContactListType do
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
