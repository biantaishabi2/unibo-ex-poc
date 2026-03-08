# Workflow: stock_quant_lifecycle_flow — 库存快照正常操作流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   _update_available_quantity --> [*]
# ```
# Workflow: stock_quant_inventory_flow — 库存盘点调整流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   _apply_inventory --> [*]
# ```
defmodule UniboV4.Inventory.StockQuant do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Inventory,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "库存快照（某库位某产品的实时数量记录，双重记账的基础）"
  end

  postgres do
    table "inventory_stock_quants"
    repo UniboV4.Repo
  end

  graphql do
    type :inventory_stock_quant

    queries do
      get :get_inventory_stock_quant, :read
      list :list_inventory_stock_quants, :read
      get :get_get_reserve_quantity_inventory_stock_quant, :get_reserve_quantity
      list :list_get_reserve_quantity_inventory_stock_quants, :get_reserve_quantity
    end

    mutations do
      create :create_inventory_stock_quant, :create
      update :update_inventory_stock_quant, :update
      update :update_available_quantity_inventory_stock_quant, :update_available_quantity
      update :apply_inventory_inventory_stock_quant, :apply_inventory
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_id, :uuid do
      allow_nil? false
      public? true
      description "产品ID"
    end
    attribute :product_code, :string do
      allow_nil? false
      public? true
      description "产品编号"
    end
    attribute :product_name, :string do
      allow_nil? false
      public? true
      description "产品名称"
    end
    attribute :quantity, :decimal do
      allow_nil? false
      default 0
      public? true
      description "在库数量"
    end
    attribute :reserved_quantity, :decimal do
      allow_nil? false
      default 0
      public? true
      description "已预留数量"
    end
    attribute :available_quantity, :decimal do
      public? true
      description "可用数量（quantity - reserved_quantity），不可直接写入"
    end
    attribute :inventory_quantity, :decimal do
      public? true
      description "盘点填写的数量"
    end
    attribute :inventory_diff_quantity, :decimal do
      public? true
      description "盘点差异（inventory_quantity - quantity）"
    end
    attribute :unit_cost, :decimal do
      public? true
      description "单位成本"
    end
    attribute :lot_number, :string do
      public? true
      description "批次号"
    end
    attribute :package_id, :uuid do
      public? true
      description "包装ID"
    end
    attribute :owner_id, :uuid do
      public? true
      description "所有者ID"
    end
    attribute :in_date, :utc_datetime do
      allow_nil? false
      public? true
      description "入库日期（FIFO/LIFO 排序用）"
    end
    attribute :is_outdated, :boolean do
      default false
      public? true
      description "盘点后是否已被其他 move 修改过"
    end
    attribute :sn_duplicated, :boolean do
      default false
      public? true
      description "同一序列号是否出现在多个 internal/transit 库位"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :warehouse, UniboV4.Inventory.Warehouse do
      public? true
      allow_nil? false
    end
    belongs_to :location, UniboV4.Inventory.StockLocation do
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
      accept [:product_id, :product_code, :product_name, :quantity, :reserved_quantity, :unit_cost, :lot_number, :in_date]
      argument :warehouse_id, :uuid, allow_nil?: false
      argument :location_id, :uuid, allow_nil?: false
      argument :lot_id, :uuid
      argument :package_id, :uuid
      argument :owner_id, :uuid
      change manage_relationship(:warehouse_id, :warehouse, type: :append, on_lookup: :relate)
      change manage_relationship(:location_id, :location, type: :append, on_lookup: :relate)
      validate present(:product_code)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:quantity, :reserved_quantity, :unit_cost]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :update_available_quantity do
      description "更新可用数量（双重记账核心方法）"
      accept []
      argument :product_id, :uuid, allow_nil?: false
      argument :location_id, :uuid, allow_nil?: false
      argument :qty, :decimal, allow_nil?: false
      argument :lot_id, :uuid
      argument :package_id, :uuid
      argument :owner_id, :uuid
      argument :in_date, :utc_datetime
      change UniboV4.Inventory.Changes.StockQuant.UpdateAvailableQuantityCall1
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    read :get_reserve_quantity do
      description "按出库策略获取可预留数量"
      argument :product_id, :uuid, allow_nil?: false
      argument :location_id, :uuid, allow_nil?: false
      argument :qty, :decimal, allow_nil?: false
      argument :removal_strategy, :string
    end
    update :apply_inventory do
      description "执行盘点调整"
      accept [:inventory_quantity]
      change UniboV4.Inventory.Changes.StockQuant.ApplyInventoryCall2
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  validations do
    validate compare(:quantity, greater_than_or_equal_to: 0)
    validate compare(:reserved_quantity, greater_than_or_equal_to: 0)
    # validation: serial_reserved_integer — 序列号产品预留数量必须为整数(1)
  end

  identities do
    identity :unique_quant, [:product_id, :location_id, :lot_id, :package_id, :owner_id]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
