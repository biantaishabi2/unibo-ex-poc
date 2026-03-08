defmodule UniboExPoc.Ofbiz.Product.ProductPromoContent do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_promo_contents"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_promo_content

    queries do
      get :get_product_product_promo_content, :read
      list :list_product_product_promo_contents, :read
    end

    mutations do
      create :create_product_product_promo_content, :create
      update :update_product_product_promo_content, :update
      destroy :delete_product_product_promo_content, :destroy
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
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product_promo, UniboExPoc.Ofbiz.Product.ProductPromo do
      public? true
    end
    belongs_to :product_content_type, UniboExPoc.Ofbiz.Product.ProductContentType do
      public? true
      source_attribute :product_promo_content_type_id
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
