defmodule UniboExPoc.Ofbiz.Common.GeoType do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Common,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "Geographic Boundary Type"
  end

  postgres do
    table "common_geo_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_common_geo_type

    queries do
      get :get_ofbiz_common_geo_type, :read
      list :list_ofbiz_common_geo_types, :read
    end

    mutations do
      create :create_ofbiz_common_geo_type, :create
      update :update_ofbiz_common_geo_type, :update
      destroy :delete_ofbiz_common_geo_type, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :geo_type_id, :string, public?: true
    attribute :has_table, :boolean, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :parent_geo_type, UniboExPoc.Ofbiz.Common.GeoType do
      public? true
      source_attribute :parent_type_id
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
