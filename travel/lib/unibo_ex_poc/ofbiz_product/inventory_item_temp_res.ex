defmodule UniboExPoc.Ofbiz.Product.InventoryItemTempRes do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_inventory_item_temp_reses"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_inventory_item_temp_res

    queries do
      get :get_product_inventory_item_temp_res, :read
      list :list_product_inventory_item_temp_ress, :read
    end

    mutations do
      create :create_product_inventory_item_temp_res, :create
      update :update_product_inventory_item_temp_res, :update
      destroy :delete_product_inventory_item_temp_res, :destroy
    end

  end

  attributes do
    attribute :visit_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :product_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :product_store_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :quantity, :decimal, public?: true
    attribute :reserved_date, :utc_datetime, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product, UniboExPoc.Ofbiz.Product.Product do
      public? true
      define_attribute? false
    end
    belongs_to :product_store, UniboExPoc.Ofbiz.Product.ProductStore do
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
