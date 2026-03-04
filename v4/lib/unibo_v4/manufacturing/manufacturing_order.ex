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
    otp_app: :unibo_v4,
    domain: UniboV4.Manufacturing,
    data_layer: AshPostgres.DataLayer,
    notifiers: [UniboV4.Manufacturing.ManufacturingOrder.Notifier]

  postgres do
    table "manufacturing_orders"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :order_number, :string do
      allow_nil? false
      public? true
    end
    attribute :product_id, :uuid do
      allow_nil? false
      public? true
    end
    attribute :product_name, :string do
      allow_nil? false
      public? true
    end
    attribute :product_code, :string do
      allow_nil? false
      public? true
    end
    attribute :product_qty, :decimal do
      allow_nil? false
      public? true
    end
    attribute :product_uom_id, :uuid do
      allow_nil? false
      public? true
    end
    attribute :qty_producing, :decimal do
      default 0
      public? true
    end
    attribute :quantity_produced, :decimal do
      default 0
      public? true
    end
    attribute :quantity, :decimal do
      allow_nil? false
      public? true
    end
    attribute :consumption, :atom do
      constraints one_of: [:flexible, :warning, :strict]
      public? true
    end
    attribute :date_start, :utc_datetime, public?: true
    attribute :date_finished, :utc_datetime, public?: true
    attribute :planned_start_date, :date, public?: true
    attribute :planned_end_date, :date, public?: true
    attribute :actual_start_date, :date, public?: true
    attribute :actual_end_date, :date, public?: true
    attribute :location_src_id, :uuid, public?: true
    attribute :location_dest_id, :uuid, public?: true
    attribute :company_id, :uuid, public?: true
    attribute :procurement_group_id, :uuid, public?: true
    attribute :backorder_sequence, :integer do
      default 0
      public? true
    end
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :status
    calculate :qty_produced, :decimal, expr(sum(move_finished_ids, field: :quantity_done, query: [filter: expr(true)]))
    # TODO: 不支持的 calculation 表达式 :production_location_id
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
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :confirm do
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
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: set_attribute :status 是 calculation，不是 attribute
      # TODO: 不支持的 change effect inherit_attribute
      # TODO: 不支持的 change effect cross_module_call
      # TODO: 不支持的 change effect cross_module_call
      # TODO: 不支持的 change effect cross_module_call
      # TODO: 不支持的 change effect cross_module_call
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
    update :start do
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
    update :produce do
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
      # skipped: validate custom : (incompatible with bulk update atomic path)
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
    update :mark_done do
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
      # TODO: 不支持的 change effect custom
      # TODO: 不支持的 change effect custom
      # TODO: 不支持的 change effect custom
      # TODO: 不支持的 change effect custom
      # TODO: 不支持的 change effect custom
      # TODO: 不支持的 change effect cross_module_call
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
    update :split_production do
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
  end

  validations do
    validate compare(:product_qty, greater_than: 0)
    validate compare(:quantity, greater_than: 0)
  end

  identities do
    identity :unique_order_number, [:order_number]
  end

end
