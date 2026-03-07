defmodule UniboExPoc.Ofbiz.Shipment.ShipmentAttribute do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Shipment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "shipment_attributes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :shipment_shipment_attribute

    queries do
      get :get_shipment_shipment_attribute, :read
      list :list_shipment_shipment_attributes, :read
    end

    mutations do
      create :create_shipment_shipment_attribute, :create
      update :update_shipment_shipment_attribute, :update
      destroy :delete_shipment_shipment_attribute, :destroy
    end

  end

  attributes do
    attribute :shipment_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :attr_name, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :attr_value, :string, public?: true
    attribute :attr_description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :shipment, UniboExPoc.Ofbiz.Shipment.Shipment do
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
