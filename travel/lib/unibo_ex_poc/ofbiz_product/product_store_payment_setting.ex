defmodule UniboExPoc.Ofbiz.Product.ProductStorePaymentSetting do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_store_payment_settings"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_store_payment_setting

    queries do
      get :get_product_product_store_payment_setting, :read
      list :list_product_product_store_payment_settings, :read
    end

    mutations do
      create :create_product_product_store_payment_setting, :create
      update :update_product_product_store_payment_setting, :update
      destroy :delete_product_product_store_payment_setting, :destroy
    end

  end

  attributes do
    attribute :payment_method_type_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :payment_service_type_enum_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :payment_service, :string, public?: true
    attribute :payment_custom_method_id, :string, public?: true
    attribute :payment_gateway_config_id, :string, public?: true
    attribute :payment_properties_path, :string, public?: true
    attribute :apply_to_all_products, :boolean, public?: true
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

  archive do
  end

end
