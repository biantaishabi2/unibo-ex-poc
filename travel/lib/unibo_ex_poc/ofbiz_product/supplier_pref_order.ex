defmodule UniboExPoc.Ofbiz.Product.SupplierPrefOrder do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_supplier_pref_orders"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_product_supplier_pref_order

    queries do
      get :get_ofbiz_product_supplier_pref_order, :read
      list :list_ofbiz_product_supplier_pref_orders, :read
    end

    mutations do
      create :create_ofbiz_product_supplier_pref_order, :create
      update :update_ofbiz_product_supplier_pref_order, :update
      destroy :delete_ofbiz_product_supplier_pref_order, :destroy
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

  archive do
  end

end
