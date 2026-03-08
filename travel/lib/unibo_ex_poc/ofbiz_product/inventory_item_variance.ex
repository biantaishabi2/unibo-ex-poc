defmodule UniboExPoc.Ofbiz.Product.InventoryItemVariance do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_inventory_item_variances"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_inventory_item_variance

    queries do
      get :get_product_inventory_item_variance, :read
      list :list_product_inventory_item_variances, :read
    end

    mutations do
      create :create_product_inventory_item_variance, :create
      update :update_product_inventory_item_variance, :update
      destroy :delete_product_inventory_item_variance, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :available_to_promise_var, :decimal, public?: true
    attribute :quantity_on_hand_var, :decimal, public?: true
    attribute :comments, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :physical_inventory, UniboExPoc.Ofbiz.Product.PhysicalInventory do
      public? true
    end
    belongs_to :variance_reason, UniboExPoc.Ofbiz.Product.VarianceReason do
      public? true
    end
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
