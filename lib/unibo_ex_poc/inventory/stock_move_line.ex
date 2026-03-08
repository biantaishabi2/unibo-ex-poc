# Workflow: stock_move_line_write_flow — 库存移动明细行写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.Inventory.StockMoveLine do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Inventory,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "库存移动明细行（实际操作记录，包含批次/包装/库位细节）"
  end

  postgres do
    table "inventory_stock_move_lines"
    repo UniboV4.Repo
  end

  graphql do
    type :inventory_stock_move_line

    queries do
      get :get_inventory_stock_move_line, :read
      list :list_inventory_stock_move_lines, :read
    end

    mutations do
      create :create_inventory_stock_move_line, :create
      update :update_inventory_stock_move_line, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_id, :uuid do
      allow_nil? false
      public? true
      description "产品ID"
    end
    attribute :product_uom_id, :string do
      allow_nil? false
      public? true
      description "计量单位"
    end
    attribute :lot_name, :string do
      public? true
      description "新建批次名（入库时可直接填写创建新批次）"
    end
    attribute :package_id, :uuid do
      public? true
      description "源包装ID"
    end
    attribute :result_package_id, :uuid do
      public? true
      description "目标包装ID"
    end
    attribute :owner_id, :uuid do
      public? true
      description "所有者ID"
    end
    attribute :quantity, :decimal do
      allow_nil? false
      default 0
      public? true
      description "实际操作数量"
    end
    attribute :reserved_uom_qty, :decimal do
      allow_nil? false
      default 0
      public? true
      description "预留数量"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :move, UniboV4.Inventory.StockMove do
      public? true
    end
    belongs_to :source_location, UniboV4.Inventory.StockLocation do
      public? true
      allow_nil? false
    end
    belongs_to :dest_location, UniboV4.Inventory.StockLocation do
      public? true
      allow_nil? false
    end
    belongs_to :lot, UniboV4.Inventory.Lot do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:product_id, :product_uom_id, :lot_name, :quantity, :reserved_uom_qty]
      argument :move_id, :uuid
      argument :source_location_id, :uuid, allow_nil?: false
      argument :dest_location_id, :uuid, allow_nil?: false
      argument :lot_id, :uuid
      argument :package_id, :uuid
      argument :result_package_id, :uuid
      argument :owner_id, :uuid
      change manage_relationship(:source_location_id, :source_location, type: :append, on_lookup: :relate)
      change manage_relationship(:dest_location_id, :dest_location, type: :append, on_lookup: :relate)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:quantity, :lot_id, :lot_name, :result_package_id]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  validations do
    validate compare(:quantity, greater_than_or_equal_to: 0)
    validate compare(:reserved_uom_qty, greater_than_or_equal_to: 0)
    # validation: lot_required_for_tracked_product — 追踪产品必须填写 lot_id 或 lot_name
    validate compare(:quantity, equal_to: 1)
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
