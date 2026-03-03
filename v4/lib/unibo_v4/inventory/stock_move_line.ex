# Workflow: stock_move_line_write_flow — 库存移动明细行写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.Inventory.StockMoveLine do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Inventory,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "inventory_stock_move_lines"
    repo UniboV4.Repo
  end

  graphql do
    type :inventory_stock_move_line

    queries do
      get :get_inventory_stock_move_line, :read
      list :list_inventory_stock_move_lines, :read
    end

    mutations do
      create :create_inventory_stock_move_line, :create
      update :update_inventory_stock_move_line, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_id, :uuid do
      allow_nil? false
      public? true
    end
    attribute :product_uom_id, :string do
      allow_nil? false
      public? true
    end
    attribute :lot_id, :uuid, public?: true
    attribute :lot_name, :string, public?: true
    attribute :package_id, :uuid, public?: true
    attribute :result_package_id, :uuid, public?: true
    attribute :owner_id, :uuid, public?: true
    attribute :quantity, :decimal do
      allow_nil? false
      default 0
      public? true
    end
    attribute :reserved_uom_qty, :decimal do
      allow_nil? false
      default 0
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :move, UniboV4.Inventory.StockMove do
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
    belongs_to :lot, UniboV4.Inventory.Lot do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:product_id, :product_uom_id, :lot_name, :quantity, :reserved_uom_qty]
      argument :move_id, :uuid
      argument :source_location_id, :uuid, allow_nil?: false
      argument :dest_location_id, :uuid, allow_nil?: false
      argument :lot_id, :uuid
      argument :package_id, :uuid
      argument :result_package_id, :uuid
      argument :owner_id, :uuid
      change manage_relationship(:source_location_id, :source_location, type: :append, on_lookup: :relate)
      change manage_relationship(:dest_location_id, :dest_location, type: :append, on_lookup: :relate)
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
      accept [:quantity, :lot_id, :lot_name, :result_package_id]
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
    validate compare(:reserved_uom_qty, greater_than_or_equal_to: 0)
    # TODO: 不支持的校验规则 custom
    # TODO: 不支持的校验规则 custom
  end

end
