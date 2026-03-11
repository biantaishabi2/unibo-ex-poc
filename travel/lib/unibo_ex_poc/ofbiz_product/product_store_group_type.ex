defmodule UniboExPoc.Ofbiz.Product.ProductStoreGroupType do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_store_group_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_product_product_store_group_type

    queries do
      get :get_ofbiz_product_product_store_group_type, :read
      list :list_ofbiz_product_product_store_group_types, :read
    end

    mutations do
      create :create_ofbiz_product_product_store_group_type, :create
      update :update_ofbiz_product_product_store_group_type, :update
      destroy :delete_ofbiz_product_product_store_group_type, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_store_group_type_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
