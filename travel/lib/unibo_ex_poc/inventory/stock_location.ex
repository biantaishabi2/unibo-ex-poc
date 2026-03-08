# Workflow: stock_location_write_flow — 库位写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.Inventory.StockLocation do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Inventory,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "库位"
  end

  postgres do
    table "inventory_stock_locations"
    repo UniboExPoc.Repo
  end

  graphql do
    type :inventory_stock_location

    queries do
      get :get_inventory_stock_location, :read
      list :list_inventory_stock_locations, :read
    end

    mutations do
      create :create_inventory_stock_location, :create
      update :update_inventory_stock_location, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "库位名称"
    end
    attribute :complete_name, :string do
      public? true
      description "完整路径名（自动计算）"
    end
    attribute :location_code, :string do
      allow_nil? false
      public? true
      description "库位编号"
    end
    attribute :usage, :atom do
      allow_nil? false
      constraints one_of: [:internal, :supplier, :customer, :inventory, :transit, :production, :view]
      public? true
      description "库位用途类型"
    end
    attribute :area, :string do
      public? true
      description "区域"
    end
    attribute :aisle, :string do
      public? true
      description "通道"
    end
    attribute :section, :string do
      public? true
      description "货架"
    end
    attribute :level, :string do
      public? true
      description "层"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :warehouse, UniboExPoc.Inventory.Warehouse do
      public? true
      allow_nil? false
    end
    belongs_to :parent_location, UniboExPoc.Inventory.StockLocation do
      public? true
    end
    has_many :child_locations, UniboExPoc.Inventory.StockLocation do
      public? true
      source_attribute :parent_location_id
      destination_attribute :parent_location_id
    end
    belongs_to :removal_strategy, UniboExPoc.Inventory.RemovalStrategy do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :location_code, :usage, :area, :aisle, :section, :level]
      argument :warehouse_id, :uuid, allow_nil?: false
      argument :parent_location_id, :uuid
      change manage_relationship(:warehouse_id, :warehouse, type: :append, on_lookup: :relate)
      validate present(:location_code)
      validate present(:name)
      validate present(:usage)
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
      accept [:name, :area, :aisle, :section, :level, :usage]
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
