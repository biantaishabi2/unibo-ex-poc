# Workflow: valuation_adjustment_line_write_flow — 估值调整行写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
# ```
defmodule UniboV4.Inventory.ValuationAdjustmentLine do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Inventory,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "inventory_valuation_adjustment_lines"
    repo UniboV4.Repo
  end

  graphql do
    type :inventory_valuation_adjustment_line

    queries do
      get :get_inventory_valuation_adjustment_line, :read
      list :list_inventory_valuation_adjustment_lines, :read
    end

    mutations do
      create :create_inventory_valuation_adjustment_line, :create
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :quantity, :decimal, public?: true
    attribute :weight, :decimal, public?: true
    attribute :volume, :decimal, public?: true
    attribute :former_cost, :decimal, public?: true
    attribute :additional_landed_cost, :decimal do
      default 0
      public? true
    end
    attribute :final_cost, :decimal, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :cost, UniboV4.Inventory.LandedCost do
      public? true
      allow_nil? false
    end
    belongs_to :cost_line, UniboV4.Inventory.LandedCostLine do
      public? true
      allow_nil? false
    end
    belongs_to :move, UniboV4.Inventory.StockMove do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
    create :create do
      primary? true
      accept [:quantity, :weight, :volume, :former_cost, :additional_landed_cost]
      argument :cost_id, :uuid, allow_nil?: false
      argument :cost_line_id, :uuid, allow_nil?: false
      argument :move_id, :uuid, allow_nil?: false
      change manage_relationship(:cost_id, :cost, type: :append, on_lookup: :relate)
      change manage_relationship(:cost_line_id, :cost_line, type: :append, on_lookup: :relate)
      change manage_relationship(:move_id, :move, type: :append, on_lookup: :relate)
      validate present(:former_cost)
      # message: "原始成本不能为空"
      validate compare(:additional_landed_cost, greater_than_or_equal_to: 0)
      # message: "附加到岸成本不能为负"
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
  end

end
