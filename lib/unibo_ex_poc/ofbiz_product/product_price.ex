defmodule UniboV4.Ofbiz.Product.ProductPrice do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_prices"
    repo UniboV4.Repo
  end

  graphql do
    type :product_product_price

    queries do
      get :get_product_product_price, :read
      list :list_product_product_prices, :read
    end

    mutations do
      create :create_product_product_price, :create
      update :update_product_product_price, :update
      destroy :delete_product_product_price, :destroy
    end

  end

  attributes do
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
    attribute :term_uom_id, :string do
      public? true
      description "主要用于周期性和使用价格，指定时间/频率度量或使用单位度量（位、分钟等）"
    end
    attribute :custom_price_calc_service, :string do
      public? true
      description "指向CustomMethod，用于指定用于计算产品单价的服务（注：此字段的更好名称可能是priceCalcCustomMethodId）"
    end
    attribute :price_without_tax, :decimal do
      public? true
      description "如果有值，始终不包含税，无论价格是否包含税"
    end
    attribute :price_with_tax, :decimal do
      public? true
      description "如果有值，始终包含税，无论价格是否包含税"
    end
    attribute :tax_amount, :decimal, public?: true
    attribute :tax_percentage, :decimal, public?: true
    attribute :tax_auth_party_id, :string, public?: true
    attribute :tax_auth_geo_id, :string, public?: true
    attribute :tax_in_price, :boolean do
      public? true
      description "如果为Y，则价格字段对给定的taxAuthPartyId/taxAuthGeoId包含税"
    end
    attribute :created_date, :utc_datetime, public?: true
    attribute :created_by_user_login, :string, public?: true
    attribute :last_modified_date, :utc_datetime, public?: true
    attribute :last_modified_by_user_login, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product, UniboV4.Ofbiz.Product.Product do
      public? true
    end
    belongs_to :product_price_type, UniboV4.Ofbiz.Product.ProductPriceType do
      public? true
    end
    belongs_to :product_price_purpose, UniboV4.Ofbiz.Product.ProductPricePurpose do
      public? true
    end
    belongs_to :product_store_group, UniboV4.Ofbiz.Product.ProductStoreGroup do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
