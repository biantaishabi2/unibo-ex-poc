defmodule UniboExPoc.Ofbiz.Product.InventoryItemTypeAttr do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_inventory_item_type_attrs"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_inventory_item_type_attr

    queries do
      get :get_product_inventory_item_type_attr, :read
      list :list_product_inventory_item_type_attrs, :read
    end

    mutations do
      create :create_product_inventory_item_type_attr, :create
      update :update_product_inventory_item_type_attr, :update
      destroy :delete_product_inventory_item_type_attr, :destroy
    end

  end

  attributes do
    attribute :inventory_item_type_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :attr_name, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :inventory_item_type, UniboExPoc.Ofbiz.Product.InventoryItemType do
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
