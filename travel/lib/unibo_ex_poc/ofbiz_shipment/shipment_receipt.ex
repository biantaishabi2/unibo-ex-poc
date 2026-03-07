defmodule UniboExPoc.Ofbiz.Shipment.ShipmentReceipt do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Shipment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "shipment_receipts"
    repo UniboExPoc.Repo
  end

  graphql do
    type :shipment_shipment_receipt

    queries do
      get :get_shipment_shipment_receipt, :read
      list :list_shipment_shipment_receipts, :read
    end

    mutations do
      create :create_shipment_shipment_receipt, :create
      update :update_shipment_shipment_receipt, :update
      destroy :delete_shipment_shipment_receipt, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :receipt_id, :string, public?: true
    attribute :shipment_item_seq_id, :string, public?: true
    attribute :shipment_package_seq_id, :string, public?: true
    attribute :order_item_seq_id, :string, public?: true
    attribute :return_id, :string, public?: true
    attribute :return_item_seq_id, :string, public?: true
    attribute :datetime_received, :utc_datetime, public?: true
    attribute :item_description, :string, public?: true
    attribute :quantity_accepted, :decimal, public?: true
    attribute :quantity_rejected, :decimal, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :inventory_item, UniboExPoc.Ofbiz.Shipment.InventoryItem do
      public? true
      attribute_type :string
    end
    belongs_to :product, UniboExPoc.Ofbiz.Shipment.Product do
      public? true
      attribute_type :string
    end
    belongs_to :order_header, UniboExPoc.Ofbiz.Shipment.OrderHeader do
      public? true
      source_attribute :order_id
      attribute_type :string
    end
    belongs_to :rejection_reason, UniboExPoc.Ofbiz.Shipment.RejectionReason do
      public? true
      source_attribute :rejection_id
      attribute_type :string
    end
    belongs_to :user_login, UniboExPoc.Ofbiz.Shipment.UserLogin do
      public? true
      source_attribute :received_by_user_login_id
      attribute_type :string
    end
    belongs_to :shipment, UniboExPoc.Ofbiz.Shipment.Shipment do
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
