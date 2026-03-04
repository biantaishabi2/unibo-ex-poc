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
    otp_app: :unibo_v4,
    domain: UniboV4.Maintenance,
    data_layer: AshPostgres.DataLayer,
    notifiers: [UniboV4.Maintenance.RepairOrder.Notifier]

  postgres do
    table "maintenance_repair_orders"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :repair_number, :string do
      allow_nil? false
      public? true
    end
    attribute :state, :atom do
      constraints one_of: [:draft, :confirmed, :under_repair, :done, :cancel]
      default :draft
      public? true
    end
    attribute :diagnosis, :string, public?: true
    attribute :repair_notes, :string, public?: true
    attribute :estimated_cost, :decimal, public?: true
    attribute :actual_cost, :decimal, public?: true
    attribute :schedule_date, :utc_datetime, public?: true
    attribute :repair_date, :date, public?: true
    attribute :completion_date, :date, public?: true
    attribute :under_warranty, :boolean do
      default false
      public? true
    end
    attribute :parts_availability_state, :atom do
      constraints one_of: [:available, :expected, :late]
      public? true
    end
    attribute :is_parts_available, :boolean, public?: true
    attribute :is_parts_late, :boolean, public?: true
    attribute :is_returned, :boolean, public?: true
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
    belongs_to :partner, UniboV4.Maintenance.Partner do
      public? true
    end
    belongs_to :company, UniboV4.Maintenance.Company do
      public? true
      allow_nil? false
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
      # TODO: 不支持的 change effect warranty_pricing
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
      # TODO: 不支持的 change effect confirm_stock_moves
      # TODO: 不支持的 change effect warranty_pricing
      # TODO: 不支持的 change effect propagate_locations
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
    update :start_repair do
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
      # TODO: 不支持的 change effect warranty_pricing
      # TODO: 不支持的 change effect propagate_locations
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
    update :complete_repair do
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
      # TODO: 不支持的 change effect cancel_zero_qty_moves
      # TODO: 不支持的 change effect create_product_move
      # TODO: 不支持的 change effect action_done_stock
      # TODO: 不支持的 change effect sync_qty_delivered
      # TODO: 不支持的 change effect warranty_pricing
      # TODO: 不支持的 change effect propagate_locations
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
      # TODO: 不支持的 change effect cancel_all_stock_moves
      # TODO: 不支持的 change effect zero_sale_order_line
      change set_attribute(:state, :cancel)
      # TODO: 不支持的 change effect warranty_pricing
      # TODO: 不支持的 change effect propagate_locations
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
    update :reset_to_draft do
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
      # TODO: 不支持的 change effect reset_stock_moves
      # TODO: 不支持的 change effect restore_sale_order_line
      change set_attribute(:state, :draft)
      # TODO: 不支持的 change effect warranty_pricing
      # TODO: 不支持的 change effect propagate_locations
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

  identities do
    identity :unique_repair_number, [:repair_number]
  end

end
