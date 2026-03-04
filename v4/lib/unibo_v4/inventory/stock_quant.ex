# Workflow: stock_quant_lifecycle_flow — 库存快照正常操作流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   _update_available_quantity --> [*]
# ```
# Workflow: stock_quant_inventory_flow — 库存盘点调整流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   _apply_inventory --> [*]
# ```
defmodule UniboV4.Inventory.StockQuant do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Inventory,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "inventory_stock_quants"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :product_id, :uuid do
      allow_nil? false
      public? true
    end
    attribute :product_code, :string do
      allow_nil? false
      public? true
    end
    attribute :product_name, :string do
      allow_nil? false
      public? true
    end
    attribute :quantity, :decimal do
      allow_nil? false
      default 0
      public? true
    end
    attribute :reserved_quantity, :decimal do
      allow_nil? false
      default 0
      public? true
    end
    attribute :available_quantity, :decimal, public?: true
    attribute :inventory_quantity, :decimal, public?: true
    attribute :inventory_diff_quantity, :decimal, public?: true
    attribute :unit_cost, :decimal, public?: true
    attribute :lot_number, :string, public?: true
    attribute :package_id, :uuid, public?: true
    attribute :owner_id, :uuid, public?: true
    attribute :in_date, :utc_datetime do
      allow_nil? false
      public? true
    end
    attribute :is_outdated, :boolean do
      default false
      public? true
    end
    attribute :sn_duplicated, :boolean do
      default false
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :warehouse, UniboV4.Inventory.Warehouse do
      public? true
      allow_nil? false
    end
    belongs_to :location, UniboV4.Inventory.StockLocation do
      public? true
      allow_nil? false
    end
    belongs_to :lot, UniboV4.Inventory.Lot do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:product_id, :product_code, :product_name, :quantity, :reserved_quantity, :unit_cost, :lot_number, :in_date]
      argument :warehouse_id, :uuid, allow_nil?: false
      argument :location_id, :uuid, allow_nil?: false
      argument :lot_id, :uuid
      argument :package_id, :uuid
      argument :owner_id, :uuid
      change manage_relationship(:warehouse_id, :warehouse, type: :append, on_lookup: :relate)
      change manage_relationship(:location_id, :location, type: :append, on_lookup: :relate)
      validate present(:product_code)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :update do
      primary? true
      accept [:quantity, :reserved_quantity, :unit_cost]
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
    update :update_available_quantity do
      accept []
      argument :product_id, :uuid, allow_nil?: false
      argument :location_id, :uuid, allow_nil?: false
      argument :qty, :decimal, allow_nil?: false
      argument :lot_id, :uuid
      argument :package_id, :uuid
      argument :owner_id, :uuid
      argument :in_date, :utc_datetime
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
    read :get_reserve_quantity do
      argument :product_id, :uuid, allow_nil?: false
      argument :location_id, :uuid, allow_nil?: false
      argument :qty, :decimal, allow_nil?: false
      argument :removal_strategy, :string
    end
    update :apply_inventory do
      accept [:inventory_quantity]
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

  validations do
    validate compare(:quantity, greater_than_or_equal_to: 0)
    validate compare(:reserved_quantity, greater_than_or_equal_to: 0)
    # TODO: 不支持的校验规则 custom
  end

  identities do
    identity :unique_quant, [:product_id, :location_id, :lot_id, :package_id, :owner_id]
  end

end
