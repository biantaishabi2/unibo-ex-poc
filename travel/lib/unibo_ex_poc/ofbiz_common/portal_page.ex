defmodule UniboExPoc.Ofbiz.Common.PortalPage do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Common,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "Defines a Portal Page"
  end

  postgres do
    table "common_portal_pages"
    repo UniboExPoc.Repo
  end

  graphql do
    type :common_portal_page

    queries do
      get :get_common_portal_page, :read
      list :list_common_portal_pages, :read
    end

    mutations do
      create :create_common_portal_page, :create
      update :update_common_portal_page, :update
      destroy :delete_common_portal_page, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :portal_page_id, :string, public?: true
    attribute :portal_page_name, :string, public?: true
    attribute :description, :string, public?: true
    attribute :owner_user_login_id, :string, public?: true
    attribute :original_portal_page_id, :string do
      public? true
      description "The system portal page this page is derived from"
    end
    attribute :sequence_num, :integer, public?: true
    attribute :security_group_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :parent_portal_page, UniboExPoc.Ofbiz.Common.PortalPage do
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
