defmodule UniboExPoc.Ofbiz.Product.ProductStoreShipmentMeth do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_store_shipment_meths"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_store_shipment_meth

    queries do
      get :get_product_product_store_shipment_meth, :read
      list :list_product_product_store_shipment_meths, :read
    end

    mutations do
      create :create_product_product_store_shipment_meth, :create
      update :update_product_product_store_shipment_meth, :update
      destroy :delete_product_product_store_shipment_meth, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_store_ship_meth_id, :string, public?: true
    attribute :product_store_id, :string, public?: true
    attribute :shipment_method_type_id, :string, public?: true
    attribute :party_id, :string, public?: true
    attribute :role_type_id, :string, public?: true
    attribute :company_party_id, :string, public?: true
    attribute :min_weight, :decimal, public?: true
    attribute :max_weight, :decimal, public?: true
    attribute :min_size, :decimal, public?: true
    attribute :max_size, :decimal, public?: true
    attribute :min_total, :decimal, public?: true
    attribute :max_total, :decimal, public?: true
    attribute :allow_usps_addr, :boolean, public?: true
    attribute :require_usps_addr, :boolean, public?: true
    attribute :allow_company_addr, :boolean, public?: true
    attribute :require_company_addr, :boolean, public?: true
    attribute :include_no_charge_items, :boolean, public?: true
    attribute :include_feature_group, :string, public?: true
    attribute :exclude_feature_group, :string, public?: true
    attribute :include_geo_id, :string, public?: true
    attribute :exclude_geo_id, :string, public?: true
    attribute :service_name, :string, public?: true
    attribute :config_props, :string, public?: true
    attribute :shipment_custom_method_id, :string, public?: true
    attribute :shipment_gateway_config_id, :string, public?: true
    attribute :sequence_number, :integer, public?: true
    attribute :allowance_percent, :decimal, public?: true
    attribute :minimum_price, :decimal, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
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
