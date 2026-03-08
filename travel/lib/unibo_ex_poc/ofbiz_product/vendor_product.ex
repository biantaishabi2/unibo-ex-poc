defmodule UniboExPoc.Ofbiz.Product.VendorProduct do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "与特定供应商和产品相关的信息，特别是对于多供应商商店。ProductStoreGroup的使用方式类似于ProductPrice"
  end

  postgres do
    table "product_vendor_products"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_vendor_product

    queries do
      get :get_product_vendor_product, :read
      list :list_product_vendor_products, :read
    end

    mutations do
      create :create_product_vendor_product, :create
      update :update_product_vendor_product, :update
      destroy :delete_product_vendor_product, :destroy
    end

  end

  attributes do
    attribute :vendor_party_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product, UniboExPoc.Ofbiz.Product.Product do
      public? true
    end
    belongs_to :product_store_group, UniboExPoc.Ofbiz.Product.ProductStoreGroup do
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
