defmodule UniboExPoc.Ofbiz.Shipment.CarrierShipmentBoxType do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Shipment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "shipment_carrier_shipment_box_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :shipment_carrier_shipment_box_type

    queries do
      get :get_shipment_carrier_shipment_box_type, :read
      list :list_shipment_carrier_shipment_box_types, :read
    end

    mutations do
      create :create_shipment_carrier_shipment_box_type, :create
      update :update_shipment_carrier_shipment_box_type, :update
      destroy :delete_shipment_carrier_shipment_box_type, :destroy
    end

  end

  attributes do
    attribute :shipment_box_type_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :party_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :packaging_type_code, :string, public?: true
    attribute :oversize_code, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :shipment_box_type, UniboExPoc.Ofbiz.Shipment.ShipmentBoxType do
      public? true
      define_attribute? false
      attribute_type :string
    end
    belongs_to :party, UniboExPoc.Ofbiz.Shipment.Party do
      public? true
      define_attribute? false
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
