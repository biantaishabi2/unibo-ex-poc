defmodule UniboV4.Purchasing.SupplierProduct do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Purchasing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "supplier_products"
    repo UniboV4.Repo
  end

  graphql do
    type :supplier_product

    queries do
      get :get_supplier_product, :read
      list :list_supplier_products, :read
    end

    mutations do
      create :create_supplier_product, :create
      update :update_supplier_product, :update
      destroy :delete_supplier_product, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_name, :string, allow_nil?: false
    attribute :product_code, :string
    attribute :unit_price, :decimal, allow_nil?: false
    attribute :currency, :string, default: "CNY"
    attribute :min_order_quantity, :integer, default: 1
    attribute :lead_time_days, :integer
    attribute :available_from, :date
    attribute :available_thru, :date
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :supplier, UniboV4.Purchasing.Supplier do
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:product_name, :product_code, :unit_price, :currency, :min_order_quantity, :lead_time_days, :available_from, :available_thru]
      argument :supplier_id, :uuid, allow_nil?: false
      change manage_relationship(:supplier_id, :supplier, type: :append, on_lookup: :relate)
    end
    update :update do
      primary? true
      accept [:unit_price, :currency, :min_order_quantity, :lead_time_days, :available_from, :available_thru]
    end
  end

  validations do
    validate compare(:unit_price, greater_than_or_equal_to: 0)
    validate compare(:min_order_quantity, greater_than: 0)
  end

end
