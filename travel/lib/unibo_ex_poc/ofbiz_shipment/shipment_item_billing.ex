defmodule UniboExPoc.Ofbiz.Shipment.ShipmentItemBilling do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Shipment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "shipment_item_billings"
    repo UniboExPoc.Repo
  end

  graphql do
    type :shipment_shipment_item_billing

    queries do
      get :get_shipment_shipment_item_billing, :read
      list :list_shipment_shipment_item_billings, :read
    end

    mutations do
      create :create_shipment_shipment_item_billing, :create
      update :update_shipment_shipment_item_billing, :update
      destroy :delete_shipment_shipment_item_billing, :destroy
    end

  end

  attributes do
    attribute :shipment_item_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :invoice_item_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :shipment, UniboExPoc.Ofbiz.Shipment.Shipment do
      public? true
      attribute_type :string
    end
    belongs_to :invoice, UniboExPoc.Ofbiz.Shipment.Invoice do
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
