defmodule UniboExPoc.Ofbiz.Product.ProductFacilityLocation do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_product_facility_locations"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_facility_location

    queries do
      get :get_product_product_facility_location, :read
      list :list_product_product_facility_locations, :read
    end

    mutations do
      create :create_product_product_facility_location, :create
      update :update_product_product_facility_location, :update
      destroy :delete_product_product_facility_location, :destroy
    end

  end

  attributes do
    attribute :product_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
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
    attribute :minimum_stock, :decimal, public?: true
    attribute :move_quantity, :decimal, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product, UniboExPoc.Ofbiz.Product.Product do
      public? true
      define_attribute? false
    end
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
