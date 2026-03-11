defmodule UniboExPoc.Ofbiz.Product.ProductFeatureApplType do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_feature_appl_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_product_product_feature_appl_type

    queries do
      get :get_ofbiz_product_product_feature_appl_type, :read
      list :list_ofbiz_product_product_feature_appl_types, :read
    end

    mutations do
      create :create_ofbiz_product_product_feature_appl_type, :create
      update :update_ofbiz_product_product_feature_appl_type, :update
      destroy :delete_ofbiz_product_product_feature_appl_type, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_feature_appl_type_id, :string, public?: true
    attribute :has_table, :boolean, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :parent_product_feature_appl_type, UniboExPoc.Ofbiz.Product.ProductFeatureApplType do
      public? true
      source_attribute :parent_type_id
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
