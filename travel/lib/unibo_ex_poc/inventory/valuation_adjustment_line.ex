# Workflow: valuation_adjustment_line_write_flow — 估值调整行写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
# ```
defmodule UniboExPoc.Inventory.ValuationAdjustmentLine do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Inventory,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "估值调整行，记录到岸成本验证后按分摊方式计算的每条库存移动调整明细"
  end

  postgres do
    table "inventory_valuation_adjustment_lines"
    repo UniboExPoc.Repo
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
    attribute :quantity, :decimal do
      public? true
      description "产品数量"
    end
    attribute :weight, :decimal do
      public? true
      description "重量"
    end
    attribute :volume, :decimal do
      public? true
      description "体积"
    end
    attribute :former_cost, :decimal do
      public? true
      description "原始成本"
    end
    attribute :additional_landed_cost, :decimal do
      default 0
      public? true
      description "附加到岸成本（分摊计算结果）"
    end
    attribute :final_cost, :decimal do
      public? true
      description "计算字段：最终成本 = former_cost + additional_landed_cost"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :cost, UniboExPoc.Inventory.LandedCost do
      public? true
      allow_nil? false
    end
    belongs_to :cost_line, UniboExPoc.Inventory.LandedCostLine do
      public? true
      allow_nil? false
    end
    belongs_to :move, UniboExPoc.Inventory.StockMove do
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
      change set_attribute(:id, expr(id))
    end
  end

end
