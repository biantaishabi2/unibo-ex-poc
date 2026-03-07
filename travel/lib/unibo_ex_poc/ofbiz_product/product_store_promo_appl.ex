defmodule UniboExPoc.Ofbiz.Product.ProductStorePromoAppl do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_store_promo_appls"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_store_promo_appl

    queries do
      get :get_product_product_store_promo_appl, :read
      list :list_product_product_store_promo_appls, :read
    end

    mutations do
      create :create_product_product_store_promo_appl, :create
      update :update_product_product_store_promo_appl, :update
      destroy :delete_product_product_store_promo_appl, :destroy
    end

  end

  attributes do
    attribute :product_store_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :product_promo_id, :uuid do
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
    attribute :manual_only, :boolean do
      public? true
      description "如果设置为Y，则不自动评估促销，仅当手动添加到购物车时才进行评估。"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product_store, UniboExPoc.Ofbiz.Product.ProductStore do
      public? true
      define_attribute? false
    end
    belongs_to :product_promo, UniboExPoc.Ofbiz.Product.ProductPromo do
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
