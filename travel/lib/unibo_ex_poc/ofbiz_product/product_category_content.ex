defmodule UniboExPoc.Ofbiz.Product.ProductCategoryContent do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_category_contents"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_category_content

    queries do
      get :get_product_product_category_content, :read
      list :list_product_product_category_contents, :read
    end

    mutations do
      create :create_product_product_category_content, :create
      update :update_product_product_category_content, :update
      destroy :delete_product_product_category_content, :destroy
    end

  end

  attributes do
    attribute :content_id, :string do
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
    attribute :purchase_from_date, :utc_datetime, public?: true
    attribute :purchase_thru_date, :utc_datetime, public?: true
    attribute :use_count_limit, :integer, public?: true
    attribute :use_days_limit, :decimal, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product_category, UniboExPoc.Ofbiz.Product.ProductCategory do
      public? true
    end
    belongs_to :product_category_content_type, UniboExPoc.Ofbiz.Product.ProductCategoryContentType do
      public? true
      source_attribute :prod_cat_content_type_id
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
