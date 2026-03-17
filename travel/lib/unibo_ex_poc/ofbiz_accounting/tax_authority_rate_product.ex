defmodule UniboExPoc.Ofbiz.Accounting.TaxAuthorityRateProduct do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_tax_authority_rate_products"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_accounting_tax_authority_rate_product

    queries do
      get :get_ofbiz_accounting_tax_authority_rate_product, :read
      list :list_ofbiz_accounting_tax_authority_rate_products, :read
    end

    mutations do
      create :create_ofbiz_accounting_tax_authority_rate_product, :create
      update :update_ofbiz_accounting_tax_authority_rate_product, :update
      destroy :delete_ofbiz_accounting_tax_authority_rate_product, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :tax_authority_rate_seq_id, :string, public?: true
    attribute :tax_auth_geo_id, :string, public?: true
    attribute :tax_auth_party_id, :string, public?: true
    attribute :product_store_id, :string, public?: true
    attribute :product_category_id, :string, public?: true
    attribute :title_transfer_enum_id, :string, public?: true
    attribute :min_item_price, :decimal, public?: true
    attribute :min_purchase, :decimal, public?: true
    attribute :tax_shipping, :boolean, public?: true
    attribute :tax_percentage, :decimal, public?: true
    attribute :tax_promotions, :boolean, public?: true
    attribute :from_date, :utc_datetime, public?: true
    attribute :thru_date, :utc_datetime, public?: true
    attribute :description, :string, public?: true
    attribute :is_tax_in_shipping_price, :boolean, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :tax_authority_rate_type, UniboExPoc.Ofbiz.Accounting.TaxAuthorityRateType do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
