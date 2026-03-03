# Workflow: landed_cost_line_write_flow — 到岸成本行写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.Inventory.LandedCostLine do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Inventory,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "inventory_landed_cost_lines"
    repo UniboV4.Repo
  end

  graphql do
    type :inventory_landed_cost_line

    queries do
      get :get_inventory_landed_cost_line, :read
      list :list_inventory_landed_cost_lines, :read
    end

    mutations do
      create :create_inventory_landed_cost_line, :create
      update :update_inventory_landed_cost_line, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :price_unit, :decimal do
      allow_nil? false
      public? true
    end
    attribute :split_method, :atom do
      allow_nil? false
      constraints one_of: [:equal, :by_quantity, :by_current_cost_price, :by_weight, :by_volume]
      default :equal
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :cost, UniboV4.Inventory.LandedCost do
      public? true
      allow_nil? false
    end
    has_many :adjustment_lines, UniboV4.Inventory.ValuationAdjustmentLine do
      public? true
      destination_attribute :cost_line_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :price_unit, :split_method]
      argument :cost_id, :uuid, allow_nil?: false
      change manage_relationship(:cost_id, :cost, type: :append, on_lookup: :relate)
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
      accept [:name, :price_unit, :split_method]
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
    validate compare(:price_unit, greater_than: 0)
  end

end
