defmodule UniboExPoc.Ofbiz.Shipment.ShippingDocument do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Shipment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "shipment_shipping_documents"
    repo UniboExPoc.Repo
  end

  graphql do
    type :shipment_shipping_document

    queries do
      get :get_shipment_shipping_document, :read
      list :list_shipment_shipping_documents, :read
    end

    mutations do
      create :create_shipment_shipping_document, :create
      update :update_shipment_shipping_document, :update
      destroy :delete_shipment_shipping_document, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :shipment_id, :string, public?: true
    attribute :shipment_item_seq_id, :string, public?: true
    attribute :shipment_package_seq_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :document, UniboExPoc.Ofbiz.Shipment.Document do
      public? true
      attribute_type :string
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
