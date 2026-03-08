defmodule UniboV4.Ofbiz.Product.InventoryItemLabel do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_inventory_item_labels"
    repo UniboV4.Repo
  end

  graphql do
    type :product_inventory_item_label

    queries do
      get :get_product_inventory_item_label, :read
      list :list_product_inventory_item_labels, :read
    end

    mutations do
      create :create_product_inventory_item_label, :create
      update :update_product_inventory_item_label, :update
      destroy :delete_product_inventory_item_label, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :inventory_item_label_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :inventory_item_label_type, UniboV4.Ofbiz.Product.InventoryItemLabelType do
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
