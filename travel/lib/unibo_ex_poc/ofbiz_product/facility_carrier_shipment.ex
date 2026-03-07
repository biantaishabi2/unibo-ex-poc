defmodule UniboExPoc.Ofbiz.Product.FacilityCarrierShipment do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_facility_carrier_shipments"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_facility_carrier_shipment

    queries do
      get :get_product_facility_carrier_shipment, :read
      list :list_product_facility_carrier_shipments, :read
    end

    mutations do
      create :create_product_facility_carrier_shipment, :create
      update :update_product_facility_carrier_shipment, :update
      destroy :delete_product_facility_carrier_shipment, :destroy
    end

  end

  attributes do
    attribute :party_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :role_type_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :shipment_method_type_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :facility, UniboExPoc.Ofbiz.Product.Facility do
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
