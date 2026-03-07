defmodule UniboExPoc.Ofbiz.Product.ProductFeatureAppl do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_feature_appls"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_feature_appl

    queries do
      get :get_product_product_feature_appl, :read
      list :list_product_product_feature_appls, :read
    end

    mutations do
      create :create_product_product_feature_appl, :create
      update :update_product_product_feature_appl, :update
      destroy :delete_product_product_feature_appl, :destroy
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
    attribute :thru_date, :utc_datetime, public?: true
    attribute :sequence_num, :integer, public?: true
    attribute :amount, :decimal, public?: true
    attribute :recurring_amount, :decimal, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product_feature_appl_type, UniboExPoc.Ofbiz.Product.ProductFeatureApplType do
      public? true
    end
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
