defmodule UniboExPoc.Ofbiz.Shipment.PicklistItem do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Shipment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "shipment_picklist_items"
    repo UniboExPoc.Repo
  end

  graphql do
    type :shipment_picklist_item

    queries do
      get :get_shipment_picklist_item, :read
      list :list_shipment_picklist_items, :read
    end

    mutations do
      create :create_shipment_picklist_item, :create
      update :update_shipment_picklist_item, :update
      destroy :delete_shipment_picklist_item, :destroy
    end

  end

  attributes do
    attribute :order_item_seq_id, :string do
      allow_nil? false
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :ship_group_seq_id, :string do
      allow_nil? false
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :quantity, :decimal, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :picklist_bin, UniboExPoc.Ofbiz.Shipment.PicklistBin do
      public? true
      attribute_type :string
    end
    belongs_to :order_header, UniboExPoc.Ofbiz.Shipment.OrderHeader do
      public? true
      source_attribute :order_id
      attribute_type :string
    end
    belongs_to :status_item, UniboExPoc.Ofbiz.Shipment.StatusItem do
      public? true
      source_attribute :item_status_id
      attribute_type :string
    end
    belongs_to :inventory_item, UniboExPoc.Ofbiz.Shipment.InventoryItem do
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
