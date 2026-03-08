defmodule UniboV4.Ofbiz.Product.SupplierProduct do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_supplier_products"
    repo UniboV4.Repo
  end

  graphql do
    type :product_supplier_product

    queries do
      get :get_product_supplier_product, :read
      list :list_product_supplier_products, :read
    end

    mutations do
      create :create_product_supplier_product, :create
      update :update_product_supplier_product, :update
      destroy :delete_product_supplier_product, :destroy
    end

  end

  attributes do
    attribute :party_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :available_from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :available_thru_date, :utc_datetime, public?: true
    attribute :standard_lead_time_days, :decimal, public?: true
    attribute :minimum_order_quantity, :decimal do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :order_qty_increments, :decimal, public?: true
    attribute :units_included, :decimal, public?: true
    attribute :quantity_uom_id, :string, public?: true
    attribute :agreement_id, :string, public?: true
    attribute :agreement_item_seq_id, :string, public?: true
    attribute :last_price, :decimal, public?: true
    attribute :shipping_price, :decimal, public?: true
    attribute :currency_uom_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :supplier_product_name, :string, public?: true
    attribute :supplier_product_id, :string, public?: true
    attribute :can_drop_ship, :boolean, public?: true
    attribute :comments, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product, UniboV4.Ofbiz.Product.Product do
      public? true
    end
    belongs_to :supplier_pref_order, UniboV4.Ofbiz.Product.SupplierPrefOrder do
      public? true
    end
    belongs_to :supplier_rating_type, UniboV4.Ofbiz.Product.SupplierRatingType do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
