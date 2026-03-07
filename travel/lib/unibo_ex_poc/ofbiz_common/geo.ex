defmodule UniboExPoc.Ofbiz.Common.Geo do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Common,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "Geographic Boundary"
  end

  postgres do
    table "common_geos"
    repo UniboExPoc.Repo
  end

  graphql do
    type :common_geo

    queries do
      get :get_common_geo, :read
      list :list_common_geos, :read
    end

    mutations do
      create :create_common_geo, :create
      update :update_common_geo, :update
      destroy :delete_common_geo, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :geo_id, :string, public?: true
    attribute :geo_name, :string, public?: true
    attribute :geo_code, :string, public?: true
    attribute :geo_sec_code, :string, public?: true
    attribute :abbreviation, :string, public?: true
    attribute :well_known_text, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :geo_type, UniboExPoc.Ofbiz.Common.GeoType do
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
