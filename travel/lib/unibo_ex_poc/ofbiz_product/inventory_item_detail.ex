defmodule UniboExPoc.Ofbiz.Product.InventoryItemDetail do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_inventory_item_details"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_inventory_item_detail

    queries do
      get :get_product_inventory_item_detail, :read
      list :list_product_inventory_item_details, :read
    end

    mutations do
      create :create_product_inventory_item_detail, :create
      update :update_product_inventory_item_detail, :update
      destroy :delete_product_inventory_item_detail, :destroy
    end

  end

  attributes do
    attribute :inventory_item_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :inventory_item_detail_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :effective_date, :utc_datetime, public?: true
    attribute :quantity_on_hand_diff, :decimal, public?: true
    attribute :available_to_promise_diff, :decimal, public?: true
    attribute :accounting_quantity_diff, :decimal, public?: true
    attribute :unit_cost, :decimal, public?: true
    attribute :order_id, :string, public?: true
    attribute :order_item_seq_id, :string, public?: true
    attribute :ship_group_seq_id, :string, public?: true
    attribute :shipment_id, :string, public?: true
    attribute :shipment_item_seq_id, :string, public?: true
    attribute :return_id, :string, public?: true
    attribute :return_item_seq_id, :string, public?: true
    attribute :work_effort_id, :string, public?: true
    attribute :fixed_asset_id, :string, public?: true
    attribute :maint_hist_seq_id, :string, public?: true
    attribute :item_issuance_id, :string, public?: true
    attribute :receipt_id, :string, public?: true
    attribute :reason_enum_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :inventory_item, UniboExPoc.Ofbiz.Product.InventoryItem do
      public? true
      define_attribute? false
    end
    belongs_to :physical_inventory, UniboExPoc.Ofbiz.Product.PhysicalInventory do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
