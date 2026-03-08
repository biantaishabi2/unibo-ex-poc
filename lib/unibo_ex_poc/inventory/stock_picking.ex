# Workflow: stock_picking_lifecycle_flow — 拣货单正常流转流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   action_confirm --> [*]
#   action_assign --> [*]
#   button_validate --> [*]
# ```
# Workflow: stock_picking_cancel_flow — 拣货单取消流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   action_confirm --> [*]
#   action_cancel --> [*]
# ```
defmodule UniboV4.Inventory.StockPicking do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Inventory,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboV4.Inventory.StockPicking.Notifier]

  resource do
    description "拣货/出入库单"
  end

  postgres do
    table "inventory_stock_pickings"
    repo UniboV4.Repo
  end

  graphql do
    type :inventory_stock_picking

    queries do
      get :get_inventory_stock_picking, :read
      list :list_inventory_stock_pickings, :read
    end

    mutations do
      create :create_inventory_stock_picking, :create
      update :action_confirm_inventory_stock_picking, :action_confirm
      update :action_assign_inventory_stock_picking, :action_assign
      update :button_validate_inventory_stock_picking, :button_validate
      update :action_cancel_inventory_stock_picking, :action_cancel
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "自动序列号（拣货单号）"
    end
    attribute :origin, :string do
      public? true
      description "来源单据号（如销售订单号、采购订单号）"
    end
    attribute :picking_type, :atom do
      allow_nil? false
      constraints one_of: [:inbound, :outbound, :internal]
      public? true
      description "入库/出库/内部调拨"
    end
    attribute :move_type, :atom do
      allow_nil? false
      constraints one_of: [:direct, :one]
      default :direct
      public? true
      description "direct=立即发货(按最快move), one=全部就绪后发货(等最慢move)"
    end
    attribute :state, :atom do
      constraints one_of: [:draft, :waiting, :confirmed, :assigned, :done, :cancel]
      default :draft
      public? true
      description "计算字段，由 move_ids 状态聚合计算，不可直接写入"
    end
    attribute :priority, :atom do
      constraints one_of: [:"0", :"1"]
      default :"0"
      public? true
      description "0=普通, 1=紧急"
    end
    attribute :scheduled_date, :utc_datetime do
      public? true
      description "计算字段，按 move_type 策略从 move_ids.date 聚合"
    end
    attribute :date_deadline, :utc_datetime do
      public? true
      description "计算字段，按 move_type 策略从 move_ids.date_deadline 聚合"
    end
    attribute :date_done, :utc_datetime do
      public? true
      description "完成时间，完成时自动写入"
    end
    attribute :is_locked, :boolean do
      default false
      public? true
      description "完成/取消后锁定，防止修改"
    end
    attribute :show_check_availability, :boolean do
      public? true
      description "是否显示检查可用性按钮"
    end
    attribute :products_availability, :string do
      public? true
      description "产品可用性摘要文本"
    end
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :move_ids, UniboV4.Inventory.StockMove do
      public? true
      destination_attribute :picking_id
    end
    belongs_to :source_location, UniboV4.Inventory.StockLocation do
      public? true
      allow_nil? false
    end
    belongs_to :dest_location, UniboV4.Inventory.StockLocation do
      public? true
      allow_nil? false
    end
    belongs_to :partner, UniboV4.Inventory.Party do
      public? true
      source_attribute :partner_party_id
    end
    belongs_to :warehouse, UniboV4.Inventory.Warehouse do
      public? true
      allow_nil? false
    end
    belongs_to :batch, UniboV4.Inventory.PickingBatch do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:origin, :picking_type, :move_type, :priority, :notes]
      argument :move_ids, {:array, :string}, allow_nil?: false
      argument :warehouse_id, :uuid, allow_nil?: false
      argument :source_location_id, :uuid, allow_nil?: false
      argument :dest_location_id, :uuid, allow_nil?: false
      argument :partner_id, :uuid
      change manage_relationship(:move_ids, :move_ids, type: :create)
      change manage_relationship(:source_location_id, :source_location, type: :append, on_lookup: :relate)
      change manage_relationship(:dest_location_id, :dest_location, type: :append, on_lookup: :relate)
      change manage_relationship(:warehouse_id, :warehouse, type: :append, on_lookup: :relate)
      validate present(:picking_type)
      change set_attribute(:id, expr(id))
    end
    update :action_confirm do
      description "确认拣货单，对所有 draft moves 调用 _action_confirm"
      primary? true
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以确认"
      change UniboV4.Inventory.Changes.StockPicking.ActionConfirmCall1
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :action_assign do
      description "检查可用性，预留库存"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current in [:confirmed, :waiting, :assigned] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must be one of %{values}", vars: %{values: [:confirmed, :waiting, :assigned]}))
        end
      end
      # message: "只有已确认/等待/已分配状态可以检查可用性"
      change UniboV4.Inventory.Changes.StockPicking.ActionAssignCall2
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :button_validate do
      description "验证/完成拣货"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current in [:assigned, :confirmed] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must be one of %{values}", vars: %{values: [:assigned, :confirmed]}))
        end
      end
      # message: "只有已分配或已确认状态可以验证"
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change UniboV4.Inventory.Changes.StockPicking.ButtonValidateCall3
      change set_attribute(:date_done, &DateTime.utc_now/0)
      change set_attribute(:priority, :"0")
      change set_attribute(:is_locked, true)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :action_cancel do
      description "取消拣货"
      accept []
      change set_attribute(:is_locked, true)
      change UniboV4.Inventory.Changes.StockPicking.ActionCancelCall7
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_picking_name, [:name]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
