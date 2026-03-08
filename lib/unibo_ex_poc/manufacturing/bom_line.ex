# Workflow: bom_line_maintenance_flow — BOM 行创建与更新流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.Manufacturing.BomLine do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Manufacturing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "BOM 行（物料组成）"
  end

  postgres do
    table "manufacturing_bom_lines"
    repo UniboV4.Repo
  end

  graphql do
    type :manufacturing_bom_line

    mutations do
      create :create_manufacturing_bom_line, :create
      update :update_manufacturing_bom_line, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_id, :uuid do
      allow_nil? false
      public? true
      description "组件产品 ID"
    end
    attribute :component_name, :string do
      allow_nil? false
      public? true
      description "组件名称"
    end
    attribute :component_code, :string do
      allow_nil? false
      public? true
      description "组件编号"
    end
    attribute :product_qty, :decimal do
      allow_nil? false
      public? true
      description "组件数量（基于 BOM 基准）"
    end
    attribute :product_uom_id, :uuid do
      allow_nil? false
      public? true
      description "组件单位"
    end
    attribute :unit, :string do
      default "PCS"
      public? true
      description "单位（兼容旧字段）"
    end
    attribute :manual_consumption, :boolean do
      default false
      public? true
      description "手动消耗标记（true=不自动设置消耗数量，需手动填写）"
    end
    attribute :bom_product_template_attribute_value_ids, :map do
      public? true
      description "变体适用性过滤条件"
    end
    attribute :sequence, :integer do
      public? true
      description "排序"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :bom, UniboV4.Manufacturing.BillOfMaterials do
      public? true
      allow_nil? false
    end
    belongs_to :operation, UniboV4.Manufacturing.RoutingOperation do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:product_id, :component_name, :component_code, :product_qty, :product_uom_id, :unit, :operation_id, :manual_consumption, :sequence]
      argument :bom_id, :uuid, allow_nil?: false
      change manage_relationship(:bom_id, :bom, type: :append, on_lookup: :relate)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:product_qty, :product_uom_id, :unit, :operation_id, :manual_consumption, :sequence]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  validations do
    validate compare(:product_qty, greater_than: 0)
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
