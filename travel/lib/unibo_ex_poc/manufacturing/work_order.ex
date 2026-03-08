# Workflow: work_order_execution_flow — 工序工单创建、执行、暂停恢复、完成与取消流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   start --> [*]
#   pause --> [*]
#   resume --> [*]
#   finish --> [*]
#   complete --> [*]
#   cancel --> [*]
# ```
defmodule UniboExPoc.Manufacturing.WorkOrder do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Manufacturing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "工序/工单"
  end

  postgres do
    table "manufacturing_work_orders"
    repo UniboExPoc.Repo
  end

  graphql do
    type :manufacturing_work_order

    queries do
      get :get_manufacturing_work_order, :read
      list :list_manufacturing_work_orders, :read
    end

    mutations do
      create :create_manufacturing_work_order, :create
      update :start_manufacturing_work_order, :start
      update :pause_manufacturing_work_order, :pause
      update :resume_manufacturing_work_order, :resume
      update :finish_manufacturing_work_order, :finish
      update :complete_manufacturing_work_order, :complete
      update :cancel_manufacturing_work_order, :cancel
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "工序名称"
    end
    attribute :sequence, :integer do
      allow_nil? false
      public? true
      description "工序顺序"
    end
    attribute :qty_producing, :decimal do
      default 0
      public? true
      description "当前生产数量"
    end
    attribute :qty_produced, :decimal do
      default 0
      public? true
      description "已完成数量"
    end
    attribute :planned_duration_hours, :decimal do
      public? true
      description "计划工时（小时，兼容旧字段）"
    end
    attribute :actual_duration_hours, :decimal do
      public? true
      description "实际工时（小时，兼容旧字段）"
    end
    attribute :date_start, :utc_datetime do
      public? true
      description "实际开始时间"
    end
    attribute :date_finished, :utc_datetime do
      public? true
      description "实际完成时间"
    end
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :duration, :decimal, expr(sum(time_ids, field: :duration, query: [filter: expr(true)]))
    calculate :duration_expected, :decimal, expr(duration)
    calculate :status, :string, expr(name)
    calculate :wo_cost, :decimal, expr(duration)
  end

  relationships do
    belongs_to :manufacturing_order, UniboExPoc.Manufacturing.ManufacturingOrder do
      public? true
      allow_nil? false
    end
    belongs_to :work_center, UniboExPoc.Manufacturing.WorkCenter do
      public? true
    end
    many_to_many :blocked_by_workorder_ids, UniboExPoc.Manufacturing.WorkOrder do
      public? true
      through UniboExPoc.Manufacturing.WorkOrderDependencyLink
      source_attribute_on_join_resource :blocked_by_workorder_id
      destination_attribute_on_join_resource :blocked_by_workorder_id
    end
    many_to_many :needed_by_workorder_ids, UniboExPoc.Manufacturing.WorkOrder do
      public? true
      through UniboExPoc.Manufacturing.WorkOrderDependencyLink
      source_attribute_on_join_resource :blocked_by_workorder_id
      destination_attribute_on_join_resource :blocked_by_workorder_id
    end
    has_many :time_ids, UniboExPoc.Manufacturing.WorkcenterProductivity do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :sequence, :planned_duration_hours, :notes]
      argument :duration_expected, :decimal
      argument :manufacturing_order_id, :uuid, allow_nil?: false
      change manage_relationship(:manufacturing_order_id, :manufacturing_order, type: :append, on_lookup: :relate)
      validate present(:name)
      # validation: no_cyclic_dependencies — 工单之间禁止循环依赖（_check_no_cyclic_dependencies）
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :start do
      description "开始工序（button_start）"
      primary? true
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :ready do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :ready}))
        end
      end
      # message: "只有就绪状态可以开始"
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有待处理状态可以开始（兼容旧逻辑）"
      # skipped: validate compare :blocked (incompatible with bulk update atomic path)
      # skipped: set_attribute :status 是 calculation，不是 attribute
      change UniboExPoc.Manufacturing.Changes.WorkOrder.StartCreateRelated4
      change UniboExPoc.Manufacturing.Changes.WorkOrder.StartCall5
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :pause do
      description "暂停工序"
      accept []
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :resume do
      description "恢复工序"
      accept []
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :finish do
      description "完成工序（button_finish）"
      accept [:actual_duration_hours, :qty_produced]
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
      change UniboExPoc.Manufacturing.Changes.WorkOrder.FinishCall6
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :complete do
      description "完成工序（兼容旧 action）"
      accept [:actual_duration_hours]
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
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :cancel do
      description "取消工序"
      accept []
      # skipped: set_attribute :status 是 calculation，不是 attribute
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
