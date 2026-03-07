defmodule UniboExPoc.Ofbiz.Common.PortletPortletCategory do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Common,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  resource do
    description "Defines Portlets included into Categories"
  end

  postgres do
    table "common_portlet_portlet_categorys"
    repo UniboExPoc.Repo
  end

  graphql do
    type :common_portlet_portlet_category

    queries do
      get :get_common_portlet_portlet_category, :read
      list :list_common_portlet_portlet_categorys, :read
    end

    mutations do
      create :create_common_portlet_portlet_category, :create
      update :update_common_portlet_portlet_category, :update
      destroy :delete_common_portlet_portlet_category, :destroy
    end

  end

  attributes do
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :portal_portlet, UniboExPoc.Ofbiz.Common.PortalPortlet do
      public? true
    end
    belongs_to :portlet_category, UniboExPoc.Ofbiz.Common.PortletCategory do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
