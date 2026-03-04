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
    otp_app: :unibo_v4,
    domain: UniboV4.Inventory,
    data_layer: AshPostgres.DataLayer,
    notifiers: [UniboV4.Inventory.StockMove.Notifier]

  postgres do
    table "inventory_stock_moves"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :product_id, :uuid do
      allow_nil? false
      public? true
    end
    attribute :product_uom_qty, :decimal do
      allow_nil? false
      public? true
    end
    attribute :product_uom, :string do
      allow_nil? false
      public? true
    end
    attribute :product_qty, :decimal, public?: true
    attribute :quantity, :decimal, public?: true
    attribute :reserved_qty, :decimal do
      default 0
      public? true
    end
    attribute :state, :atom do
      constraints one_of: [:draft, :waiting, :confirmed, :partially_available, :assigned, :done, :cancel]
      default :draft
      public? true
    end
    attribute :date, :utc_datetime do
      allow_nil? false
      public? true
    end
    attribute :date_deadline, :utc_datetime, public?: true
    attribute :priority, :atom do
      constraints one_of: [:"0", :"1"]
      default :"0"
      public? true
    end
    attribute :procure_method, :atom do
      allow_nil? false
      constraints one_of: [:make_to_stock, :make_to_order]
      default :make_to_stock
      public? true
    end
    attribute :is_inventory, :boolean do
      default false
      public? true
    end
    attribute :availability, :decimal, public?: true
    attribute :forecast_availability, :decimal, public?: true
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
        if current in [:confirmed, :partially_available, :waiting] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must be one of %{values}", vars: %{values: [:confirmed, :partially_available, :waiting]}))
        end
      end
      # message: "只有已确认/部分可用/等待状态可以预留"
      change set_attribute(:state, :assigned)
      change set_attribute(:state, :partially_available)
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
    update :action_done do
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
      # TODO: 不支持的 change effect invoke
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
    update :action_cancel do
      accept []
      change set_attribute(:state, :cancel)
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
    update :trigger_assign do
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

end
