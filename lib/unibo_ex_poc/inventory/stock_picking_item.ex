# Workflow: stock_picking_item_write_flow — 拣货明细行写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.Inventory.StockPickingItem do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Inventory,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "拣货明细（简化版拣货行）"
  end

  postgres do
    table "inventory_stock_picking_items"
    repo UniboExPoc.Repo
  end

  graphql do
    type :inventory_stock_picking_item

    mutations do
      create :create_inventory_stock_picking_item, :create
      update :update_inventory_stock_picking_item, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_name, :string do
      allow_nil? false
      public? true
    end
    attribute :product_code, :string, public?: true
    attribute :quantity_planned, :decimal do
      allow_nil? false
      public? true
      description "计划数量"
    end
    attribute :quantity_done, :decimal do
      default 0
      public? true
      description "实际拣货数量"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :picking, UniboExPoc.Inventory.StockPicking do
      public? true
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
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:quantity_done]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  validations do
    validate compare(:quantity_planned, greater_than: 0)
    validate compare(:quantity_done, greater_than_or_equal_to: 0)
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
