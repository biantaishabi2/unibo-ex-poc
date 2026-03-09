defmodule UniboExPoc.Ofbiz.Common.GeoPoint do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Common,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "Geographic Location"
  end

  postgres do
    table "common_geo_points"
    repo UniboExPoc.Repo
  end

  graphql do
    type :common_geo_point

    queries do
      get :get_common_geo_point, :read
      list :list_common_geo_points, :read
    end

    mutations do
      create :create_common_geo_point, :create
      update :update_common_geo_point, :update
      destroy :delete_common_geo_point, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :geo_point_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :latitude, :decimal, public?: true
    attribute :longitude, :decimal, public?: true
    attribute :elevation, :decimal, public?: true
    attribute :information, :string do
      public? true
      description "To enter any related information"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :data_source, UniboExPoc.Ofbiz.Common.DataSource do
      public? true
    end
    belongs_to :geo_point_type_enumeration, UniboExPoc.Ofbiz.Common.Enumeration do
      public? true
      source_attribute :geo_point_type_enum_id
    end
    belongs_to :elevation_uom, UniboExPoc.Ofbiz.Common.Uom do
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
