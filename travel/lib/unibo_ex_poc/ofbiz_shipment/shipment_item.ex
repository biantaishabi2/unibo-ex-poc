defmodule UniboExPoc.Ofbiz.Shipment.ShipmentItem do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Shipment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "shipment_items"
    repo UniboExPoc.Repo
  end

  graphql do
    type :shipment_shipment_item

    queries do
      get :get_shipment_shipment_item, :read
      list :list_shipment_shipment_items, :read
    end

    mutations do
      create :create_shipment_shipment_item, :create
      update :update_shipment_shipment_item, :update
      destroy :delete_shipment_shipment_item, :destroy
    end

  end

  attributes do
    attribute :shipment_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :shipment_item_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :quantity, :decimal, public?: true
    attribute :shipment_content_description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :shipment, UniboExPoc.Ofbiz.Shipment.Shipment do
      public? true
      define_attribute? false
      attribute_type :string
    end
    belongs_to :product, UniboExPoc.Ofbiz.Shipment.Product do
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
