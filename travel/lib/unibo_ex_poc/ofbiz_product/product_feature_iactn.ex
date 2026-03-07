defmodule UniboExPoc.Ofbiz.Product.ProductFeatureIactn do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_feature_iactns"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_feature_iactn

    queries do
      get :get_product_product_feature_iactn, :read
      list :list_product_product_feature_iactns, :read
    end

    mutations do
      create :create_product_product_feature_iactn, :create
      update :update_product_product_feature_iactn, :update
      destroy :delete_product_product_feature_iactn, :destroy
    end

  end

  attributes do
    attribute :product_feature_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :product_feature_id_to, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :product_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product_feature_iactn_type, UniboExPoc.Ofbiz.Product.ProductFeatureIactnType do
      public? true
    end
    belongs_to :main_product_feature, UniboExPoc.Ofbiz.Product.ProductFeature do
      public? true
      source_attribute :product_feature_id
      define_attribute? false
    end
    belongs_to :assoc_product_feature, UniboExPoc.Ofbiz.Product.ProductFeature do
      public? true
      source_attribute :product_feature_id_to
      define_attribute? false
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
