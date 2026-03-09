# Workflow: landed_cost_picking_write_flow — 到岸成本-拣货单关联写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
# ```
defmodule UniboExPoc.Inventory.LandedCostPicking do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Inventory,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "到岸成本与拣货单的多对多桥接实体"
  end

  postgres do
    table "inventory_landed_cost_pickings"
    repo UniboExPoc.Repo
  end

  graphql do
    type :inventory_landed_cost_picking

    queries do
      get :get_inventory_landed_cost_picking, :read
      list :list_inventory_landed_cost_pickings, :read
    end

    mutations do
      create :create_inventory_landed_cost_picking, :create
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :landed_cost, UniboExPoc.Inventory.LandedCost do
      public? true
      allow_nil? false
    end
    belongs_to :picking, UniboExPoc.Inventory.StockPicking do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
    create :create do
      primary? true
      accept []
      argument :landed_cost_id, :uuid, allow_nil?: false
      argument :picking_id, :uuid, allow_nil?: false
      change manage_relationship(:landed_cost_id, :landed_cost, type: :append, on_lookup: :relate)
      change manage_relationship(:picking_id, :picking, type: :append, on_lookup: :relate)
      validate present(:landed_cost_id)
      # message: "到岸成本ID不能为空"
      validate present(:picking_id)
      # message: "拣货单ID不能为空"
      change set_attribute(:id, expr(id))
    end
  end

end
