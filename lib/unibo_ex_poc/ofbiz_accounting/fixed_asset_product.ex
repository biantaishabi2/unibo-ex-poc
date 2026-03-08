defmodule UniboV4.Ofbiz.Accounting.FixedAssetProduct do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_fixed_asset_products"
    repo UniboV4.Repo
  end

  graphql do
    type :accounting_fixed_asset_product

    queries do
      get :get_accounting_fixed_asset_product, :read
      list :list_accounting_fixed_asset_products, :read
    end

    mutations do
      create :create_accounting_fixed_asset_product, :create
      update :update_accounting_fixed_asset_product, :update
      destroy :delete_accounting_fixed_asset_product, :destroy
    end

  end

  attributes do
    attribute :product_id, :string do
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
    attribute :comments, :string, public?: true
    attribute :sequence_num, :integer, public?: true
    attribute :quantity, :decimal, public?: true
    attribute :quantity_uom_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :fixed_asset, UniboV4.Ofbiz.Accounting.FixedAsset do
      public? true
    end
    belongs_to :fixed_asset_product_type, UniboV4.Ofbiz.Accounting.FixedAssetProductType do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
