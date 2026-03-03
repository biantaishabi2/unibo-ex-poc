# Workflow: warehouse_write_flow — 仓库写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.Inventory.Warehouse do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Inventory,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "inventory_warehouses"
    repo UniboV4.Repo
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
    end
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :status, :atom do
      constraints one_of: [:active, :inactive]
      default :active
      public? true
    end
    attribute :address, :string, public?: true
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :locations, UniboV4.Inventory.StockLocation do
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
      accept [:name, :address, :description, :status]
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
    identity :unique_warehouse_code, [:warehouse_code]
  end

end
