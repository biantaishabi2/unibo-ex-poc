defmodule UniboExPoc.Ofbiz.Product.FacilityLocation do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_facility_locations"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_facility_location

    queries do
      get :get_product_facility_location, :read
      list :list_product_facility_locations, :read
    end

    mutations do
      create :create_product_facility_location, :create
      update :update_product_facility_location, :update
      destroy :delete_product_facility_location, :destroy
    end

  end

  attributes do
    attribute :facility_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :location_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :location_type_enum_id, :string, public?: true
    attribute :area_id, :string, public?: true
    attribute :aisle_id, :string, public?: true
    attribute :section_id, :string, public?: true
    attribute :level_id, :string, public?: true
    attribute :position_id, :string, public?: true
    attribute :geo_point_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :facility, UniboExPoc.Ofbiz.Product.Facility do
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
