defmodule UniboExPoc.Ofbiz.Product.InventoryItemLabelAppl do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_inventory_item_label_appls"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_inventory_item_label_appl

    queries do
      get :get_product_inventory_item_label_appl, :read
      list :list_product_inventory_item_label_appls, :read
    end

    mutations do
      create :create_product_inventory_item_label_appl, :create
      update :update_product_inventory_item_label_appl, :update
      destroy :delete_product_inventory_item_label_appl, :destroy
    end

  end

  attributes do
    attribute :inventory_item_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :inventory_item_label_type_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :sequence_num, :integer, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :inventory_item, UniboExPoc.Ofbiz.Product.InventoryItem do
      public? true
      define_attribute? false
    end
    belongs_to :inventory_item_label_type, UniboExPoc.Ofbiz.Product.InventoryItemLabelType do
      public? true
      define_attribute? false
    end
    belongs_to :inventory_item_label, UniboExPoc.Ofbiz.Product.InventoryItemLabel do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
