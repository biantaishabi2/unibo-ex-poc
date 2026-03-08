defmodule UniboV4.Ofbiz.Product.FacilityLocationGeoPoint do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_facility_location_geo_points"
    repo UniboV4.Repo
  end

  graphql do
    type :product_facility_location_geo_point

    queries do
      get :get_product_facility_location_geo_point, :read
      list :list_product_facility_location_geo_points, :read
    end

    mutations do
      create :create_product_facility_location_geo_point, :create
      update :update_product_facility_location_geo_point, :update
      destroy :delete_product_facility_location_geo_point, :destroy
    end

  end

  attributes do
    attribute :facility_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :location_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :geo_point_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
