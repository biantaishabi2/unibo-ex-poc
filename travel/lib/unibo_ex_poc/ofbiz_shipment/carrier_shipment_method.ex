defmodule UniboExPoc.Ofbiz.Shipment.CarrierShipmentMethod do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Shipment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "shipment_carrier_shipment_methods"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_shipment_carrier_shipment_method

    queries do
      get :get_ofbiz_shipment_carrier_shipment_method, :read
      list :list_ofbiz_shipment_carrier_shipment_methods, :read
    end

    mutations do
      create :create_ofbiz_shipment_carrier_shipment_method, :create
      update :update_ofbiz_shipment_carrier_shipment_method, :update
      destroy :delete_ofbiz_shipment_carrier_shipment_method, :destroy
    end

  end

  attributes do
    attribute :role_type_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :sequence_number, :integer, public?: true
    attribute :carrier_service_code, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :shipment_method_type, UniboExPoc.Ofbiz.Shipment.ShipmentMethodType do
      public? true
      attribute_type :string
    end
    belongs_to :party, UniboExPoc.Ofbiz.Shipment.Party do
      public? true
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
