# Workflow: stock_move_lifecycle_flow — 库存移动正常流转流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   _action_confirm --> [*]
#   _action_assign --> [*]
#   _action_done --> [*]
#   _trigger_assign --> [*]
# ```
# Workflow: stock_move_cancel_flow — 库存移动取消流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   _action_confirm --> [*]
#   _action_cancel --> [*]
# ```
defmodule UniboV4.Inventory.StockMove do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Inventory,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboV4.Inventory.StockMove.Notifier]

  resource do
    description "库存移动行（单个产品的移动记录）"
  end

  postgres do
    table "inventory_stock_moves"
    repo UniboV4.Repo
  end

  graphql do
    type :inventory_stock_move

    queries do
      get :get_inventory_stock_move, :read
      list :list_inventory_stock_moves, :read
    end

    mutations do
      create :create_inventory_stock_move, :create
      update :action_confirm_inventory_stock_move, :action_confirm
      update :action_assign_inventory_stock_move, :action_assign
      update :action_done_inventory_stock_move, :action_done
      update :action_cancel_inventory_stock_move, :action_cancel
      update :trigger_assign_inventory_stock_move, :trigger_assign
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "移动描述"
    end
    attribute :product_id, :uuid do
      allow_nil? false
      public? true
      description "产品ID"
    end
    attribute :product_uom_qty, :decimal do
      allow_nil? false
      public? true
      description "需求数量（用户计量单位）"
    end
    attribute :product_uom, :string do
      allow_nil? false
      public? true
      description "用户计量单位"
    end
    attribute :product_qty, :decimal do
      public? true
      description "基础UOM数量（自动换算）"
    end
    attribute :quantity, :decimal do
      public? true
      description "实际已完成数量（sum of move_line_ids.quantity）"
    end
    attribute :reserved_qty, :decimal do
      default 0
      public? true
      description "已预留数量"
    end
    attribute :state, :atom do
      constraints one_of: [:draft, :waiting, :confirmed, :partially_available, :assigned, :done, :cancel]
      default :draft
      public? true
      description "移动状态"
    end
    attribute :date, :utc_datetime do
      allow_nil? false
      public? true
      description "计划日期"
    end
    attribute :date_deadline, :utc_datetime do
      public? true
      description "截止日期"
    end
    attribute :priority, :atom do
      constraints one_of: [:"0", :"1"]
      default :"0"
      public? true
      description "0=普通, 1=紧急"
    end
    attribute :procure_method, :atom do
      allow_nil? false
      constraints one_of: [:make_to_stock, :make_to_order]
      default :make_to_stock
      public? true
      description "make_to_stock=从现有库存, make_to_order=按需采购"
    end
    attribute :is_inventory, :boolean do
      default false
      public? true
      description "是否为库存调整产生的 move（防止循环处理）"
    end
    attribute :availability, :decimal do
      public? true
      description "当前预留比例"
    end
    attribute :forecast_availability, :decimal do
      public? true
      description "预测可用量"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :picking, UniboV4.Inventory.StockPicking do
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
    has_many :move_line_ids, UniboV4.Inventory.StockMoveLine do
      public? true
      destination_attribute :move_id
    end
    many_to_many :move_orig_ids, UniboV4.Inventory.StockMove do
      public? true
      through UniboV4.Inventory.StockMoveDependencyLink
      source_attribute_on_join_resource :move_orig_id
      destination_attribute_on_join_resource :move_orig_id
    end
    many_to_many :move_dest_ids, UniboV4.Inventory.StockMove do
      public? true
      through UniboV4.Inventory.StockMoveDependencyLink
      source_attribute_on_join_resource :move_orig_id
      destination_attribute_on_join_resource :move_orig_id
    end
    has_many :valuation_adjustment_lines, UniboV4.Inventory.ValuationAdjustmentLine do
      public? true
      destination_attribute :move_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :product_id, :product_uom_qty, :product_uom, :date, :date_deadline, :priority, :procure_method]
      argument :picking_id, :uuid
      argument :source_location_id, :uuid, allow_nil?: false
      argument :dest_location_id, :uuid, allow_nil?: false
      change manage_relationship(:source_location_id, :source_location, type: :append, on_lookup: :relate)
      change manage_relationship(:dest_location_id, :dest_location, type: :append, on_lookup: :relate)
      argument :move_line_ids, {:array, :map}, default: []
      change manage_relationship(:move_line_ids, :move_line_ids, type: :create)
      validate present(:name)
      validate present(:product_id)
      validate compare(:product_uom_qty, greater_than: 0)
      # message: "需求数量必须大于零"
      change set_attribute(:id, expr(id))
    end
    update :action_confirm do
      description "确认移动，可合并同产品/同库位的 moves"
      primary? true
      accept []
      argument :merge, :boolean
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以确认"
      change set_attribute(:state, :confirmed)
      change set_attribute(:state, :waiting)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :action_assign do
      description "预留库存"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current in [:confirmed, :partially_available, :waiting] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must be one of %{values}", vars: %{values: [:confirmed, :partially_available, :waiting]}))
        end
      end
      # message: "只有已确认/部分可用/等待状态可以预留"
      change set_attribute(:state, :assigned)
      change set_attribute(:state, :partially_available)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :action_done do
      description "完成移动，执行双重记账"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current in [:confirmed, :partially_available, :assigned] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must be one of %{values}", vars: %{values: [:confirmed, :partially_available, :assigned]}))
        end
      end
      # message: "只有已确认/部分可用/已分配状态可以完成"
      change set_attribute(:state, :done)
      change UniboV4.Inventory.Changes.StockMove.ActionDoneCall6
      change UniboV4.Inventory.Changes.StockMove.ActionDoneCall7
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :action_cancel do
      description "取消移动，释放预留"
      accept []
      change set_attribute(:state, :cancel)
      change UniboV4.Inventory.Changes.StockMove.ActionCancelCall9
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :trigger_assign do
      description "触发下游 moves 的库存预留"
      accept []
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
