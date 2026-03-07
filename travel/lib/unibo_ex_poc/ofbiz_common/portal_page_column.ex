defmodule UniboExPoc.Ofbiz.Common.PortalPageColumn do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Common,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  resource do
    description "Defines a Portal Page"
  end

  postgres do
    table "common_portal_page_columns"
    repo UniboExPoc.Repo
  end

  graphql do
    type :common_portal_page_column

    queries do
      get :get_common_portal_page_column, :read
      list :list_common_portal_page_columns, :read
    end

    mutations do
      create :create_common_portal_page_column, :create
      update :update_common_portal_page_column, :update
      destroy :delete_common_portal_page_column, :destroy
    end

  end

  attributes do
    attribute :portal_page_id, :uuid do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :column_seq_id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :column_width_pixels, :integer, public?: true
    attribute :column_width_percentage, :integer, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :portal_page, UniboExPoc.Ofbiz.Common.PortalPage do
      public? true
      define_attribute? false
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
