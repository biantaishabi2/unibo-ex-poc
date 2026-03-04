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
    otp_app: :unibo_v4,
    domain: UniboV4.Inventory,
    data_layer: AshPostgres.DataLayer,
    notifiers: [UniboV4.Inventory.StockPicking.Notifier]

  postgres do
    table "inventory_stock_pickings"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :origin, :string, public?: true
    attribute :picking_type, :atom do
      allow_nil? false
      constraints one_of: [:inbound, :outbound, :internal]
      public? true
    end
    attribute :move_type, :atom do
      allow_nil? false
      constraints one_of: [:direct, :one]
      default :direct
      public? true
    end
    attribute :state, :atom do
      constraints one_of: [:draft, :waiting, :confirmed, :assigned, :done, :cancel]
      default :draft
      public? true
    end
    attribute :priority, :atom do
      constraints one_of: [:"0", :"1"]
      default :"0"
      public? true
    end
    attribute :scheduled_date, :utc_datetime, public?: true
    attribute :date_deadline, :utc_datetime, public?: true
    attribute :date_done, :utc_datetime, public?: true
    attribute :is_locked, :boolean do
      default false
      public? true
    end
    attribute :show_check_availability, :boolean, public?: true
    attribute :products_availability, :string, public?: true
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
    belongs_to :partner, UniboV4.Inventory.Partner do
      public? true
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
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :action_confirm do
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
      # TODO: 不支持的 change effect invoke
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
    update :action_assign do
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
      # TODO: 不支持的 change effect invoke
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
    update :button_validate do
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
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # TODO: 不支持的 change effect invoke
      change set_attribute(:date_done, &DateTime.utc_now/0)
      change set_attribute(:priority, :"0")
      change set_attribute(:is_locked, true)
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
    update :action_cancel do
      accept []
      change set_attribute(:is_locked, true)
      # TODO: 不支持的 change effect invoke
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
    identity :unique_picking_name, [:name]
  end

end
