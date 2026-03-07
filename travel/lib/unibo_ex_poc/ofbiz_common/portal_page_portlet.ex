defmodule UniboExPoc.Ofbiz.Common.PortalPagePortlet do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Common,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  resource do
    description "Defines Portlets included into Portal Pages"
  end

  postgres do
    table "common_portal_page_portlets"
    repo UniboExPoc.Repo
  end

  graphql do
    type :common_portal_page_portlet

    queries do
      get :get_common_portal_page_portlet, :read
      list :list_common_portal_page_portlets, :read
    end

    mutations do
      create :create_common_portal_page_portlet, :create
      update :update_common_portal_page_portlet, :update
      destroy :delete_common_portal_page_portlet, :destroy
    end

  end

  attributes do
    attribute :portal_page_id, :uuid do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :portal_portlet_id, :uuid do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :portlet_seq_id, :string do
      primary_key? true
      allow_nil? false
      public? true
      description "Identify the portalPortlet instance in case more copy of the same portalPortlet are present in the same portalPage"
    end
    attribute :column_seq_id, :string, public?: true
    attribute :sequence_num, :integer, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :portal_page, UniboExPoc.Ofbiz.Common.PortalPage do
      public? true
      define_attribute? false
    end
    belongs_to :portal_portlet, UniboExPoc.Ofbiz.Common.PortalPortlet do
      public? true
      define_attribute? false
    end
    belongs_to :portal_page_column, UniboExPoc.Ofbiz.Common.PortalPageColumn do
      public? true
      source_attribute :portal_page_id
      define_attribute? false
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
