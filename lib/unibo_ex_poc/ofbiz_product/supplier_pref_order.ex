defmodule UniboV4.Ofbiz.Product.SupplierPrefOrder do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_supplier_pref_orders"
    repo UniboV4.Repo
  end

  graphql do
    type :product_supplier_pref_order

    queries do
      get :get_product_supplier_pref_order, :read
      list :list_product_supplier_pref_orders, :read
    end

    mutations do
      create :create_product_supplier_pref_order, :create
      update :update_product_supplier_pref_order, :update
      destroy :delete_product_supplier_pref_order, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :supplier_pref_order_id, :string, public?: true
    attribute :description, :string, public?: true
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
