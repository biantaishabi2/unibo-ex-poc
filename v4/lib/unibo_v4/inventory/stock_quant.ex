defmodule UniboV4.Inventory.StockQuant do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Inventory,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "stock_quants"
    repo UniboV4.Repo
  end

  graphql do
    type :stock_quant

    queries do
      get :get_stock_quant, :read
      list :list_stock_quants, :read
    end

    mutations do
      create :create_stock_quant, :create
      update :update_stock_quant, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_code, :string, allow_nil?: false
    attribute :product_name, :string, allow_nil?: false
    attribute :quantity_on_hand, :decimal, default: 0
    attribute :quantity_reserved, :decimal, default: 0
    attribute :unit_cost, :decimal
    attribute :lot_number, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :warehouse, UniboV4.Inventory.Warehouse do
      allow_nil? false
    end
    belongs_to :location, UniboV4.Inventory.StockLocation
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:product_code, :product_name, :quantity_on_hand, :quantity_reserved, :unit_cost, :lot_number]
      argument :warehouse_id, :uuid, allow_nil?: false
      change manage_relationship(:warehouse_id, :warehouse, type: :append, on_lookup: :relate)
      validate present(:product_code)
    end
    update :update do
      primary? true
      accept [:quantity_on_hand, :quantity_reserved, :unit_cost]
    end
  end

  validations do
    validate compare(:quantity_on_hand, greater_than_or_equal_to: 0)
  end

end
