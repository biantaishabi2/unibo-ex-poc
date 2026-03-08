# Workflow: manufacturing_order_flow — 生产工单创建、确认、开工、产出、完工与欠产拆分流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   confirm --> [*]
#   start --> [*]
#   produce --> [*]
#   mark_done --> [*]
#   complete --> [*]
#   split_production --> [*]
#   cancel --> [*]
# ```
defmodule UniboV4.Manufacturing.ManufacturingOrder do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Manufacturing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboV4.Manufacturing.ManufacturingOrder.Notifier]

  resource do
    description "生产工单"
  end

  postgres do
    table "manufacturing_orders"
    repo UniboV4.Repo
  end

  graphql do
    type :manufacturing_manufacturing_order

    queries do
      get :get_manufacturing_manufacturing_order, :read
      list :list_manufacturing_manufacturing_orders, :read
    end

    mutations do
      create :create_manufacturing_manufacturing_order, :create
      update :confirm_manufacturing_manufacturing_order, :confirm
      update :start_manufacturing_manufacturing_order, :start
      update :produce_manufacturing_manufacturing_order, :produce
      update :mark_done_manufacturing_manufacturing_order, :mark_done
      update :complete_manufacturing_manufacturing_order, :complete
      update :cancel_manufacturing_manufacturing_order, :cancel
      update :split_production_manufacturing_manufacturing_order, :split_production
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "序号，自动生成（sequence）"
    end
    attribute :order_number, :string do
      allow_nil? false
      public? true
      description "工单编号"
    end
    attribute :product_id, :uuid do
      allow_nil? false
      public? true
      description "成品产品 ID"
    end
    attribute :product_name, :string do
      allow_nil? false
      public? true
      description "产品名称"
    end
    attribute :product_code, :string do
      allow_nil? false
      public? true
    end
    attribute :product_qty, :decimal do
      allow_nil? false
      public? true
      description "计划生产数量"
    end
    attribute :product_uom_id, :uuid do
      allow_nil? false
      public? true
      description "成品单位"
    end
    attribute :qty_producing, :decimal do
      default 0
      public? true
      description "当前正在生产的数量"
    end
    attribute :quantity_produced, :decimal do
      default 0
      public? true
      description "已生产数量（兼容旧字段）"
    end
    attribute :quantity, :decimal do
      allow_nil? false
      public? true
      description "计划生产数量（兼容旧字段）"
    end
    attribute :consumption, :atom do
      constraints one_of: [:flexible, :warning, :strict]
      public? true
      description "消耗模式（从 BOM 继承）"
    end
    attribute :date_start, :utc_datetime do
      public? true
      description "计划开始时间"
    end
    attribute :date_finished, :utc_datetime do
      public? true
      description "计划完成时间"
    end
    attribute :planned_start_date, :date do
      public? true
      description "计划开始日期（兼容旧字段）"
    end
    attribute :planned_end_date, :date do
      public? true
      description "计划结束日期（兼容旧字段）"
    end
    attribute :actual_start_date, :date, public?: true
    attribute :actual_end_date, :date, public?: true
    attribute :location_src_id, :uuid do
      public? true
      description "原料来源库位"
    end
    attribute :location_dest_id, :uuid do
      public? true
      description "成品目标库位"
    end
    attribute :company_id, :uuid do
      public? true
      description "公司"
    end
    attribute :procurement_group_id, :uuid do
      public? true
      description "采购/调拨组（欠产工单共享此 ID）"
    end
    attribute :backorder_sequence, :integer do
      default 0
      public? true
      description "欠产工单序号"
    end
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :status, :string, expr(name)
    calculate :qty_produced, :decimal, expr(sum(move_finished_ids, field: :quantity_done, query: [filter: expr(true)]))
    calculate :production_location_id, :string, expr(location_dest_id)
  end

  relationships do
    belongs_to :bom, UniboV4.Manufacturing.BillOfMaterials do
      public? true
    end
    has_many :work_orders, UniboV4.Manufacturing.WorkOrder do
      public? true
    end
    belongs_to :work_center, UniboV4.Manufacturing.WorkCenter do
      public? true
    end
    has_many :move_raw_ids, UniboV4.Manufacturing.StockMove do
      public? true
      destination_attribute :raw_material_production_id
    end
    has_many :move_finished_ids, UniboV4.Manufacturing.StockMove do
      public? true
      destination_attribute :production_id
    end
    has_many :picking_ids, UniboV4.Manufacturing.StockPicking do
      public? true
      destination_attribute :production_id
    end
    has_many :scrap_ids, UniboV4.Manufacturing.StockScrap do
      public? true
      destination_attribute :production_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:order_number, :product_id, :product_name, :product_code, :product_qty, :product_uom_id, :quantity, :planned_start_date, :planned_end_date, :date_start, :date_finished, :location_src_id, :location_dest_id, :company_id, :notes]
      argument :bom_id, :uuid
      validate present(:order_number)
      change set_attribute(:id, expr(id))
    end
    update :confirm do
      description "确认工单（action_confirm）"
      primary? true
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以确认"
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: set_attribute :status 是 calculation，不是 attribute
      change UniboV4.Manufacturing.Changes.ManufacturingOrder.ConfirmCall5
      change UniboV4.Manufacturing.Changes.ManufacturingOrder.ConfirmCall6
      change UniboV4.Manufacturing.Changes.ManufacturingOrder.ConfirmCall7
      change UniboV4.Manufacturing.Changes.ManufacturingOrder.ConfirmCall8
      change UniboV4.Manufacturing.Changes.ManufacturingOrder.ConfirmCall9
      change UniboV4.Manufacturing.Changes.ManufacturingOrder.ConfirmCall10
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :start do
      description "开始生产（通过 WO button_start 或直接 produce 触发）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :confirmed do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :confirmed}))
        end
      end
      # message: "只有已确认状态可以开始"
      # skipped: set_attribute :status 是 calculation，不是 attribute
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :produce do
      description "记录生产产出"
      accept [:qty_producing]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :progress do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :progress}))
        end
      end
      # message: "只有进行中状态可以记录产出"
      # skipped: validate compare :qty_producing (incompatible with bulk update atomic path)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :mark_done do
      description "完工入库（button_mark_done → _post_inventory）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :to_close do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :to_close}))
        end
      end
      # message: "只有待关闭状态可以完工入库"
      # skipped: set_attribute :status 是 calculation，不是 attribute
      change UniboV4.Manufacturing.Changes.ManufacturingOrder.MarkDoneCall11
      change UniboV4.Manufacturing.Changes.ManufacturingOrder.MarkDoneCall12
      change UniboV4.Manufacturing.Changes.ManufacturingOrder.MarkDoneCall13
      change UniboV4.Manufacturing.Changes.ManufacturingOrder.MarkDoneCall14
      change UniboV4.Manufacturing.Changes.ManufacturingOrder.MarkDoneCall15
      change UniboV4.Manufacturing.Changes.ManufacturingOrder.MarkDoneCall16
      change UniboV4.Manufacturing.Changes.ManufacturingOrder.MarkDoneCall17
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :complete do
      description "完成生产（兼容旧 action）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :progress do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :progress}))
        end
      end
      # message: "只有进行中状态可以完成"
      # skipped: set_attribute :status 是 calculation，不是 attribute
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :cancel do
      description "取消工单"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:draft, :confirmed, :progress] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:draft, :confirmed, :progress]}))
        end
      end
      # message: "非完工状态才可取消"
      # skipped: set_attribute :status 是 calculation，不是 attribute
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :split_production do
      description "创建欠产工单（_split_productions），为未完成数量创建后续 MO"
      accept []
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  validations do
    validate compare(:product_qty, greater_than: 0)
    validate compare(:quantity, greater_than: 0)
  end

  identities do
    identity :unique_order_number, [:order_number]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
