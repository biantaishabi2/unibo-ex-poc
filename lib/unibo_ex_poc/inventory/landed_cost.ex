# Workflow: landed_cost_lifecycle_flow — 到岸成本正常流转流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   button_validate --> [*]
# ```
# Workflow: landed_cost_cancel_flow — 到岸成本取消流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   button_cancel --> [*]
# ```
defmodule UniboExPoc.Inventory.LandedCost do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Inventory,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "到岸成本，将运费、关税等附加成本分摊到入库产品上"
  end

  postgres do
    table "inventory_landed_costs"
    repo UniboExPoc.Repo
  end

  graphql do
    type :inventory_landed_cost

    queries do
      get :get_inventory_landed_cost, :read
      list :list_inventory_landed_costs, :read
    end

    mutations do
      create :create_inventory_landed_cost, :create
      update :update_inventory_landed_cost, :update
      update :button_validate_inventory_landed_cost, :button_validate
      update :button_cancel_inventory_landed_cost, :button_cancel
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "名称，序列号自动生成"
    end
    attribute :date, :date do
      allow_nil? false
      default &Date.utc_today/0
      public? true
      description "到岸成本日期"
    end
    attribute :state, :atom do
      constraints one_of: [:draft, :done, :cancel]
      default :draft
      public? true
      description "状态：草稿/已验证/已取消"
    end
    attribute :description, :string do
      public? true
      description "描述说明"
    end
    attribute :amount_total, :decimal do
      public? true
      description "计算字段：成本行总金额"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :cost_lines, UniboExPoc.Inventory.LandedCostLine do
      public? true
      destination_attribute :cost_id
    end
    has_many :valuation_adjustment_lines, UniboExPoc.Inventory.ValuationAdjustmentLine do
      public? true
      destination_attribute :cost_id
    end
    many_to_many :picking_ids, UniboExPoc.Inventory.StockPicking do
      public? true
      through UniboExPoc.Inventory.LandedCostPicking
      destination_attribute_on_join_resource :picking_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:date, :description]
      argument :cost_lines, {:array, :map}, default: []
      change manage_relationship(:cost_lines, :cost_lines, type: :create)
      validate present(:date)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:date, :description]
      argument :cost_lines, {:array, :map}, default: []
      change manage_relationship(:cost_lines, :cost_lines, on_lookup: :relate, on_no_match: :create, on_match: :update)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :button_validate do
      description "验证到岸成本：按分摊方式计算估值调整、更新产品成本价、状态 → done"
      accept []
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :button_cancel do
      description "取消到岸成本（仅 draft 状态可取消）"
      accept []
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
