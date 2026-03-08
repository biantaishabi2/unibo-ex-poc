defmodule UniboV4.Ofbiz.Product.ProductKeyword do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_keywords"
    repo UniboV4.Repo
  end

  graphql do
    type :product_product_keyword

    queries do
      get :get_product_product_keyword, :read
      list :list_product_product_keywords, :read
    end

    mutations do
      create :create_product_product_keyword, :create
      update :update_product_product_keyword, :update
      destroy :delete_product_product_keyword, :destroy
    end

  end

  attributes do
    attribute :keyword, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :keyword_type_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :relevancy_weight, :integer, public?: true
    attribute :status_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product, UniboV4.Ofbiz.Product.Product do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
