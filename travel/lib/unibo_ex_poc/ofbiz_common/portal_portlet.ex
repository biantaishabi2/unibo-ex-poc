defmodule UniboExPoc.Ofbiz.Common.PortalPortlet do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Common,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "Defines a Portlet to be used in Portals"
  end

  postgres do
    table "common_portal_portlets"
    repo UniboExPoc.Repo
  end

  graphql do
    type :common_portal_portlet

    queries do
      get :get_common_portal_portlet, :read
      list :list_common_portal_portlets, :read
    end

    mutations do
      create :create_common_portal_portlet, :create
      update :update_common_portal_portlet, :update
      destroy :delete_common_portal_portlet, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :portal_portlet_id, :string, public?: true
    attribute :portlet_name, :string, public?: true
    attribute :screen_name, :string, public?: true
    attribute :screen_location, :string, public?: true
    attribute :edit_form_name, :string, public?: true
    attribute :edit_form_location, :string, public?: true
    attribute :description, :string, public?: true
    attribute :screenshot, :string, public?: true
    attribute :security_service_name, :string do
      public? true
      description "The service named here is used to see if current user can see the portlet on the list of available portlets; the screen that the portlet calls should also call this service to check permission and not render; the service named here must implement the \"permissionInterface\" service just like services used for service permissions"
    end
    attribute :security_main_action, :string do
      public? true
      description "The main action which can be done with this portlet, possible values: CREATE UPDATE VIEW DELETE"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
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
