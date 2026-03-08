defmodule UniboV4.Ofbiz.Product.ProductStoreVendorShipment do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  resource do
    description "用于定义与商店相关的供应商将接受的承运人和装运方式组合（针对多供应商商店）"
  end

  postgres do
    table "product_store_vendor_shipments"
    repo UniboV4.Repo
  end

  graphql do
    type :product_product_store_vendor_shipment

    queries do
      get :get_product_product_store_vendor_shipment, :read
      list :list_product_product_store_vendor_shipments, :read
    end

    mutations do
      create :create_product_product_store_vendor_shipment, :create
      update :update_product_product_store_vendor_shipment, :update
      destroy :delete_product_product_store_vendor_shipment, :destroy
    end

  end

  attributes do
    attribute :vendor_party_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :shipment_method_type_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :carrier_party_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product_store, UniboV4.Ofbiz.Product.ProductStore do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
