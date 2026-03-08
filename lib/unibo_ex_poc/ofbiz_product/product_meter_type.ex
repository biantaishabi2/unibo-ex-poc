defmodule UniboV4.Ofbiz.Product.ProductMeterType do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_meter_types"
    repo UniboV4.Repo
  end

  graphql do
    type :product_product_meter_type

    queries do
      get :get_product_product_meter_type, :read
      list :list_product_product_meter_types, :read
    end

    mutations do
      create :create_product_product_meter_type, :create
      update :update_product_product_meter_type, :update
      destroy :delete_product_product_meter_type, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_meter_type_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :default_uom_id, :string do
      public? true
      description "此字段为可选，如适用，可更好地描述计量器"
    end
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
