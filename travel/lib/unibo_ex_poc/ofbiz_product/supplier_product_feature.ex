defmodule UniboExPoc.Ofbiz.Product.SupplierProductFeature do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_supplier_product_features"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_supplier_product_feature

    queries do
      get :get_product_supplier_product_feature, :read
      list :list_product_supplier_product_features, :read
    end

    mutations do
      create :create_product_supplier_product_feature, :create
      update :update_product_supplier_product_feature, :update
      destroy :delete_product_supplier_product_feature, :destroy
    end

  end

  attributes do
    attribute :party_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :description, :string, public?: true
    attribute :uom_id, :string, public?: true
    attribute :id_code, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product_feature, UniboExPoc.Ofbiz.Product.ProductFeature do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
