defmodule UniboExPoc.Ofbiz.Common.PortletAttribute do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Common,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "Allows to set different attribute values for each instance of the same portlet"
  end

  postgres do
    table "common_portlet_attributes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :common_portlet_attribute

    queries do
      get :get_common_portlet_attribute, :read
      list :list_common_portlet_attributes, :read
    end

    mutations do
      create :create_common_portlet_attribute, :create
      update :update_common_portlet_attribute, :update
      destroy :delete_common_portlet_attribute, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :portal_page_id, :string, public?: true
    attribute :portlet_seq_id, :string, public?: true
    attribute :attr_name, :string, public?: true
    attribute :attr_value, :string, public?: true
    attribute :attr_description, :string, public?: true
    attribute :attr_type, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :portal_portlet, UniboExPoc.Ofbiz.Common.PortalPortlet do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  identities do
    identity :unique_portlet_attr, [:portal_page_id, :portlet_seq_id, :attr_name]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
