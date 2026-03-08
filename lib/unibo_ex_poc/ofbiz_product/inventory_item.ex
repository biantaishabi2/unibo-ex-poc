defmodule UniboV4.Ofbiz.Product.InventoryItem do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_inventory_items"
    repo UniboV4.Repo
  end

  graphql do
    type :product_inventory_item

    queries do
      get :get_product_inventory_item, :read
      list :list_product_inventory_items, :read
    end

    mutations do
      create :create_product_inventory_item, :create
      update :update_product_inventory_item, :update
      destroy :delete_product_inventory_item, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :inventory_item_id, :string, public?: true
    attribute :party_id, :string, public?: true
    attribute :owner_party_id, :string do
      public? true
      description "库存品的所有者"
    end
    attribute :status_id, :string, public?: true
    attribute :datetime_received, :utc_datetime, public?: true
    attribute :datetime_manufactured, :utc_datetime, public?: true
    attribute :expire_date, :utc_datetime, public?: true
    attribute :uom_id, :string, public?: true
    attribute :bin_number, :string, public?: true
    attribute :location_seq_id, :string, public?: true
    attribute :comments, :string, public?: true
    attribute :quantity_on_hand_total, :decimal, public?: true
    attribute :available_to_promise_total, :decimal, public?: true
    attribute :accounting_quantity_total, :decimal, public?: true
    attribute :serial_number, :string, public?: true
    attribute :soft_identifier, :string, public?: true
    attribute :activation_number, :string, public?: true
    attribute :activation_valid_thru, :utc_datetime, public?: true
    attribute :unit_cost, :decimal do
      public? true
      description "更高精度，以防是计算的数字"
    end
    attribute :currency_uom_id, :string do
      public? true
      description "单位成本的货币计量单位"
    end
    attribute :fixed_asset_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :inventory_item_type, UniboV4.Ofbiz.Product.InventoryItemType do
      public? true
    end
    belongs_to :product, UniboV4.Ofbiz.Product.Product do
      public? true
    end
    belongs_to :facility, UniboV4.Ofbiz.Product.Facility do
      public? true
    end
    belongs_to :container, UniboV4.Ofbiz.Product.Container do
      public? true
    end
    belongs_to :lot, UniboV4.Ofbiz.Product.Lot do
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
