defmodule UniboExPoc.Ofbiz.Product.MarketInterest do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_market_interests"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_market_interest

    queries do
      get :get_product_market_interest, :read
      list :list_product_market_interests, :read
    end

    mutations do
      create :create_product_market_interest, :create
      update :update_product_market_interest, :update
      destroy :delete_product_market_interest, :destroy
    end

  end

  attributes do
    attribute :party_classification_group_id, :string do
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
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product_category, UniboExPoc.Ofbiz.Product.ProductCategory do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
