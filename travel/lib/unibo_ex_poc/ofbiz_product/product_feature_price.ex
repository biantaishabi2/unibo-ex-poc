defmodule UniboExPoc.Ofbiz.Product.ProductFeaturePrice do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_feature_prices"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_feature_price

    queries do
      get :get_product_product_feature_price, :read
      list :list_product_product_feature_prices, :read
    end

    mutations do
      create :create_product_product_feature_price, :create
      update :update_product_product_feature_price, :update
      destroy :delete_product_product_feature_price, :destroy
    end

  end

  attributes do
    attribute :product_feature_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :product_price_type_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :currency_uom_id, :string do
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
    attribute :price, :decimal, public?: true
    attribute :created_date, :utc_datetime, public?: true
    attribute :created_by_user_login, :string, public?: true
    attribute :last_modified_date, :utc_datetime, public?: true
    attribute :last_modified_by_user_login, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product_price_type, UniboExPoc.Ofbiz.Product.ProductPriceType do
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
