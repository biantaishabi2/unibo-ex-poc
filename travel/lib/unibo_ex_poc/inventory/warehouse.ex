# Workflow: warehouse_write_flow — 仓库写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.Inventory.Warehouse do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Inventory,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "仓库"
  end

  postgres do
    table "inventory_warehouses"
    repo UniboExPoc.Repo
  end

  graphql do
    type :inventory_warehouse

    queries do
      get :get_inventory_warehouse, :read
      list :list_inventory_warehouses, :read
    end

    mutations do
      create :create_inventory_warehouse, :create
      update :update_inventory_warehouse, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :warehouse_code, :string do
      allow_nil? false
      public? true
      description "仓库编号"
    end
    attribute :name, :string do
      allow_nil? false
      public? true
      description "仓库名称"
    end
    attribute :status, :atom do
      constraints one_of: [:active, :inactive]
      default :active
      public? true
    end
    attribute :address, :string do
      public? true
      description "仓库地址"
    end
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :locations, UniboExPoc.Inventory.StockLocation do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:warehouse_code, :name, :address, :description]
      validate present(:warehouse_code)
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :address, :description, :status]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_warehouse_code, [:warehouse_code]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
