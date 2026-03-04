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
defmodule UniboV4.Manufacturing.WorkOrder do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Manufacturing,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "manufacturing_work_orders"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :sequence, :integer do
      allow_nil? false
      public? true
    end
    attribute :qty_producing, :decimal do
      default 0
      public? true
    end
    attribute :qty_produced, :decimal do
      default 0
      public? true
    end
    attribute :planned_duration_hours, :decimal, public?: true
    attribute :actual_duration_hours, :decimal, public?: true
    attribute :date_start, :utc_datetime, public?: true
    attribute :date_finished, :utc_datetime, public?: true
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :duration, :decimal, expr(sum(time_ids, field: :duration, query: [filter: expr(true)]))
    # TODO: 不支持的 calculation 表达式 :duration_expected
    # TODO: 不支持的 calculation 表达式 :status
    # TODO: 不支持的 calculation 表达式 :wo_cost
  end

  relationships do
    belongs_to :manufacturing_order, UniboV4.Manufacturing.ManufacturingOrder do
      public? true
      allow_nil? false
    end
    belongs_to :work_center, UniboV4.Manufacturing.WorkCenter do
      public? true
    end
    many_to_many :blocked_by_workorder_ids, UniboV4.Manufacturing.WorkOrder do
      public? true
      through UniboV4.Manufacturing.WorkOrderDependencyLink
      source_attribute_on_join_resource :needed_by_workorder_id
      destination_attribute_on_join_resource :needed_by_workorder_id
    end
    many_to_many :needed_by_workorder_ids, UniboV4.Manufacturing.WorkOrder do
      public? true
      through UniboV4.Manufacturing.WorkOrderDependencyLink
      source_attribute_on_join_resource :needed_by_workorder_id
      destination_attribute_on_join_resource :needed_by_workorder_id
    end
    has_many :time_ids, UniboV4.Manufacturing.WorkcenterProductivity do
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
      # TODO: 不支持的 action 内校验规则 custom
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
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: set_attribute :status 是 calculation，不是 attribute
      # TODO: 不支持的 change effect create_record
      # TODO: 不支持的 change effect cross_module_call
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
      # TODO: 不支持的 change effect custom
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

end
