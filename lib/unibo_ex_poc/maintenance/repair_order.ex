# Workflow: repair_order_lifecycle — 维修工单生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> confirm
#   create --> cancel
#   confirm --> start_repair
#   confirm --> cancel
#   start_repair --> complete_repair
#   start_repair --> cancel
#   complete_repair --> [*]
#   cancel --> reset_to_draft
#   reset_to_draft --> confirm
# ```
defmodule UniboV4.Maintenance.RepairOrder do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboV4.Maintenance.RepairOrder.Notifier]

  resource do
    description "维修工单，5 态状态机，支持零件消耗和库存移动"
  end

  postgres do
    table "maintenance_repair_orders"
    repo UniboV4.Repo
  end

  graphql do
    type :maintenance_repair_order

    queries do
      get :get_maintenance_repair_order, :read
      list :list_maintenance_repair_orders, :read
    end

    mutations do
      create :create_maintenance_repair_order, :create
      update :confirm_maintenance_repair_order, :confirm
      update :start_repair_maintenance_repair_order, :start_repair
      update :complete_repair_maintenance_repair_order, :complete_repair
      update :cancel_maintenance_repair_order, :cancel
      update :reset_to_draft_maintenance_repair_order, :reset_to_draft
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :repair_number, :string do
      allow_nil? false
      public? true
      description "维修单编号（自动序列号）"
    end
    attribute :state, :atom do
      constraints one_of: [:draft, :confirmed, :under_repair, :done, :cancel]
      default :draft
      public? true
      description "状态机: draft->confirmed->under_repair->done/cancel, cancel->draft"
    end
    attribute :diagnosis, :string do
      public? true
      description "故障诊断"
    end
    attribute :repair_notes, :string, public?: true
    attribute :estimated_cost, :decimal do
      public? true
      description "预估费用"
    end
    attribute :actual_cost, :decimal do
      public? true
      description "实际费用"
    end
    attribute :schedule_date, :utc_datetime do
      public? true
      description "计划维修日期"
    end
    attribute :repair_date, :date, public?: true
    attribute :completion_date, :date, public?: true
    attribute :under_warranty, :boolean do
      default false
      public? true
      description "保修期内标记，为 true 时所有零件行 price_unit 强制为 0"
    end
    attribute :parts_availability_state, :atom do
      constraints one_of: [:available, :expected, :late]
      public? true
      description "零件可用性状态：
available: 所有零件库存充足
expected: 库存不足但预测在 schedule_date 前到货
late: 库存不足且预测无法按期到货
"
    end
    attribute :is_parts_available, :boolean, public?: true
    attribute :is_parts_late, :boolean, public?: true
    attribute :is_returned, :boolean do
      public? true
      description "关联退货 picking 是否完成"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :equipment, UniboV4.Maintenance.Equipment do
      public? true
      allow_nil? false
    end
    belongs_to :product, UniboV4.Maintenance.Product do
      public? true
      allow_nil? false
    end
    belongs_to :lot, UniboV4.Maintenance.Lot do
      public? true
    end
    belongs_to :partner, UniboV4.Maintenance.Party do
      public? true
      source_attribute :partner_party_id
    end
    belongs_to :company, UniboV4.Maintenance.Party do
      public? true
      allow_nil? false
      source_attribute :company_party_id
    end
    belongs_to :location, UniboV4.Maintenance.StockLocation do
      public? true
      allow_nil? false
    end
    belongs_to :location_dest, UniboV4.Maintenance.StockLocation do
      public? true
      allow_nil? false
    end
    has_many :parts, UniboV4.Maintenance.RepairOrderLine do
      public? true
      destination_attribute :repair_order_id
    end
    has_many :stock_moves, UniboV4.Maintenance.StockMove do
      public? true
      destination_attribute :repair_order_id
    end
    belongs_to :product_move, UniboV4.Maintenance.StockMove do
      public? true
    end
    belongs_to :sale_order, UniboV4.Maintenance.SalesOrder do
      public? true
    end
    belongs_to :picking, UniboV4.Maintenance.StockPicking do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:repair_number, :diagnosis, :repair_notes, :estimated_cost, :schedule_date, :repair_date, :under_warranty]
      argument :equipment_id, :uuid, allow_nil?: false
      argument :product_id, :uuid, allow_nil?: false
      argument :location_id, :uuid, allow_nil?: false
      argument :location_dest_id, :uuid, allow_nil?: false
      change manage_relationship(:equipment_id, :equipment, type: :append, on_lookup: :relate)
      change manage_relationship(:product_id, :product, type: :append, on_lookup: :relate)
      argument :company_id, :uuid, allow_nil?: false
      change manage_relationship(:company_id, :company, type: :append, on_lookup: :relate)
      change manage_relationship(:location_id, :location, type: :append, on_lookup: :relate)
      change manage_relationship(:location_dest_id, :location_dest, type: :append, on_lookup: :relate)
      validate present(:repair_number)
      change UniboV4.Maintenance.Changes.RepairOrder.CreateCall15
      change set_attribute(:id, expr(id))
    end
    update :confirm do
      description "确认维修 (draft -> confirmed)"
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
      # skipped: validate parts_quantity_positive : (incompatible with bulk update atomic path)
      # skipped: validate lot_stock_check : (incompatible with bulk update atomic path)
      change set_attribute(:state, :confirmed)
      change UniboV4.Maintenance.Changes.RepairOrder.ConfirmCall2
      change UniboV4.Maintenance.Changes.RepairOrder.ConfirmCall15
      change UniboV4.Maintenance.Changes.RepairOrder.ConfirmCall16
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :start_repair do
      description "开始维修 (confirmed -> under_repair)"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :confirmed do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :confirmed}))
        end
      end
      # message: "只有已确认状态可以开始维修"
      change set_attribute(:state, :under_repair)
      change UniboV4.Maintenance.Changes.RepairOrder.StartRepairCall15
      change UniboV4.Maintenance.Changes.RepairOrder.StartRepairCall16
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :complete_repair do
      description "完成维修 (under_repair -> done)"
      accept [:actual_cost]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :under_repair do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :under_repair}))
        end
      end
      # message: "只有维修中状态可以完成"
      change set_attribute(:state, :done)
      change UniboV4.Maintenance.Changes.RepairOrder.CompleteRepairCall5
      change UniboV4.Maintenance.Changes.RepairOrder.CompleteRepairCall6
      change UniboV4.Maintenance.Changes.RepairOrder.CompleteRepairCall7
      change UniboV4.Maintenance.Changes.RepairOrder.CompleteRepairCall8
      change UniboV4.Maintenance.Changes.RepairOrder.CompleteRepairCall15
      change UniboV4.Maintenance.Changes.RepairOrder.CompleteRepairCall16
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :cancel do
      description "取消维修 (any -> cancel)"
      accept []
      change UniboV4.Maintenance.Changes.RepairOrder.CancelCall9
      change UniboV4.Maintenance.Changes.RepairOrder.CancelCall10
      change set_attribute(:state, :cancel)
      change UniboV4.Maintenance.Changes.RepairOrder.CancelCall15
      change UniboV4.Maintenance.Changes.RepairOrder.CancelCall16
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :reset_to_draft do
      description "重置为草稿 (cancel -> draft)"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :cancel do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :cancel}))
        end
      end
      # message: "只有已取消状态可以重置为草稿"
      change UniboV4.Maintenance.Changes.RepairOrder.ResetToDraftCall12
      change UniboV4.Maintenance.Changes.RepairOrder.ResetToDraftCall13
      change set_attribute(:state, :draft)
      change UniboV4.Maintenance.Changes.RepairOrder.ResetToDraftCall15
      change UniboV4.Maintenance.Changes.RepairOrder.ResetToDraftCall16
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_repair_number, [:repair_number]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
