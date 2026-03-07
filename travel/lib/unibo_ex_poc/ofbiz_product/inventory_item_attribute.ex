defmodule UniboExPoc.Ofbiz.Product.InventoryItemAttribute do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_inventory_item_attributes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_inventory_item_attribute

    queries do
      get :get_product_inventory_item_attribute, :read
      list :list_product_inventory_item_attributes, :read
    end

    mutations do
      create :create_product_inventory_item_attribute, :create
      update :update_product_inventory_item_attribute, :update
      destroy :delete_product_inventory_item_attribute, :destroy
    end

  end

  attributes do
    attribute :attr_name, :string do
      allow_nil? false
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :attr_value, :string, public?: true
    attribute :attr_description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :inventory_item, UniboExPoc.Ofbiz.Product.InventoryItem do
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
