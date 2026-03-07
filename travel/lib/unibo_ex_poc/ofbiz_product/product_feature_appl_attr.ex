defmodule UniboExPoc.Ofbiz.Product.ProductFeatureApplAttr do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_feature_appl_attrs"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_feature_appl_attr

    queries do
      get :get_product_product_feature_appl_attr, :read
      list :list_product_product_feature_appl_attrs, :read
    end

    mutations do
      create :create_product_product_feature_appl_attr, :create
      update :update_product_product_feature_appl_attr, :update
      destroy :delete_product_product_feature_appl_attr, :destroy
    end

  end

  attributes do
    attribute :product_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :product_feature_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :attr_name, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :attr_value, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product, UniboExPoc.Ofbiz.Product.Product do
      public? true
      define_attribute? false
    end
    belongs_to :product_feature, UniboExPoc.Ofbiz.Product.ProductFeature do
      public? true
      define_attribute? false
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
