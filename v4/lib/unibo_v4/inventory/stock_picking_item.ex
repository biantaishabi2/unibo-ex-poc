defmodule UniboV4.Inventory.StockPickingItem do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Inventory,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "stock_picking_items"
    repo UniboV4.Repo
  end

  graphql do
    type :stock_picking_item

    mutations do
      create :create_stock_picking_item, :create
      update :update_stock_picking_item, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_name, :string, allow_nil?: false
    attribute :product_code, :string
    attribute :quantity_planned, :decimal, allow_nil?: false
    attribute :quantity_done, :decimal, default: 0
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :picking, UniboV4.Inventory.StockPicking do
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:product_name, :product_code, :quantity_planned]
      argument :picking_id, :uuid, allow_nil?: false
      change manage_relationship(:picking_id, :picking, type: :append, on_lookup: :relate)
    end
    update :update do
      primary? true
      accept [:quantity_done]
    end
  end

  validations do
    validate compare(:quantity_planned, greater_than: 0)
    validate compare(:quantity_done, greater_than_or_equal_to: 0)
  end

end
