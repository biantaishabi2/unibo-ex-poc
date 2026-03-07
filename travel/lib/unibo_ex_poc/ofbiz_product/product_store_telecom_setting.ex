defmodule UniboExPoc.Ofbiz.Product.ProductStoreTelecomSetting do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_store_telecom_settings"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_store_telecom_setting

    queries do
      get :get_product_product_store_telecom_setting, :read
      list :list_product_product_store_telecom_settings, :read
    end

    mutations do
      create :create_product_product_store_telecom_setting, :create
      update :update_product_product_store_telecom_setting, :update
      destroy :delete_product_product_store_telecom_setting, :destroy
    end

  end

  attributes do
    attribute :telecom_method_type_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :telecom_msg_type_enum_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :telecom_custom_method_id, :string, public?: true
    attribute :telecom_gateway_config_id, :string, public?: true
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
