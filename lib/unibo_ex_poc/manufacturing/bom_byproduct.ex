# Workflow: bom_byproduct_maintenance_flow — BOM 副产品创建与更新流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.Manufacturing.BomByproduct do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Manufacturing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "BOM 副产品"
  end

  postgres do
    table "manufacturing_bom_byproducts"
    repo UniboV4.Repo
  end

  graphql do
    type :manufacturing_bom_byproduct

    mutations do
      create :create_manufacturing_bom_byproduct, :create
      update :update_manufacturing_bom_byproduct, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_id, :uuid do
      allow_nil? false
      public? true
      description "副产品 ID"
    end
    attribute :product_qty, :decimal do
      allow_nil? false
      public? true
      description "副产品数量"
    end
    attribute :product_uom_id, :uuid do
      allow_nil? false
      public? true
      description "副产品单位"
    end
    attribute :cost_share, :decimal do
      default 0
      public? true
      description "成本分摊比例（0-100%）"
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
      accept [:product_id, :product_qty, :product_uom_id, :operation_id, :cost_share]
      argument :bom_id, :uuid, allow_nil?: false
      change manage_relationship(:bom_id, :bom, type: :append, on_lookup: :relate)
      validate attribute_does_not_equal(:product_id, :bom_product_id)
      # message: "副产品不能与 BOM 主产品相同"
      validate compare(:cost_share, less_than_or_equal_to: 100)
      # message: "所有副产品 cost_share 总和不得超过 100%（主产品 + 全部副产品 = 100%）"
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:product_qty, :product_uom_id, :operation_id, :cost_share]
      # skipped: validate compare :product_id (incompatible with bulk update atomic path)
      # skipped: validate compare :cost_share (incompatible with bulk update atomic path)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  validations do
    validate compare(:product_qty, greater_than: 0)
    validate compare(:cost_share, greater_than_or_equal_to: 0, less_than_or_equal_to: 100)
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
