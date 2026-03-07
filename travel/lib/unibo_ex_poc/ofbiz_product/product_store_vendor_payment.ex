defmodule UniboExPoc.Ofbiz.Product.ProductStoreVendorPayment do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "用于定义与商店相关的供应商将接受的支付方式（针对多供应商商店）"
  end

  postgres do
    table "product_store_vendor_payments"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_store_vendor_payment

    queries do
      get :get_product_product_store_vendor_payment, :read
      list :list_product_product_store_vendor_payments, :read
    end

    mutations do
      create :create_product_product_store_vendor_payment, :create
      update :update_product_product_store_vendor_payment, :update
      destroy :delete_product_product_store_vendor_payment, :destroy
    end

  end

  attributes do
    attribute :vendor_party_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :payment_method_type_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :credit_card_enum_id, :string do
      allow_nil? false
      primary_key? true
      public? true
      description "如果不适用于paymentMethodTypeId，使用\"_NA_\""
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product_store, UniboExPoc.Ofbiz.Product.ProductStore do
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
