defmodule UniboExPoc.Ofbiz.Product.InventoryItemVariance do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

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
    attribute :inventory_item_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :physical_inventory_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :available_to_promise_var, :decimal, public?: true
    attribute :quantity_on_hand_var, :decimal, public?: true
    attribute :comments, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :physical_inventory, UniboExPoc.Ofbiz.Product.PhysicalInventory do
      public? true
      define_attribute? false
    end
    belongs_to :variance_reason, UniboExPoc.Ofbiz.Product.VarianceReason do
      public? true
    end
    belongs_to :inventory_item, UniboExPoc.Ofbiz.Product.InventoryItem do
      public? true
      define_attribute? false
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
