# Workflow: bom_activation_sync — BOM 激活后同步草稿制造单
# ```mermaid
# stateDiagram-v2
#   [*] --> evaluate_activation
#   evaluate_activation --> sync_draft_mo
#   sync_draft_mo --> [*]
# ```
# Workflow: bom_where_used_analysis — BOM where-used 反查流程
# ```mermaid
# stateDiagram-v2
#   [*] --> collect_component_usages
#   collect_component_usages --> build_recursive_bom_tree
#   build_recursive_bom_tree --> [*]
# ```
# Workflow: bom_component_delta_impact — BOM 组件增删导致的供应链影响评估
# ```mermaid
# stateDiagram-v2
#   [*] --> detect_component_delta
#   detect_component_delta --> sync_procurement_stock_impact
#   sync_procurement_stock_impact --> [*]
# ```
defmodule UniboExPoc.PLM.BomRevision do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.PLM,
    data_layer: AshPostgres.DataLayer

  resource do
    description "BOM 版本管理扩展，追踪版本链路和变更历史"
  end

  postgres do
    table "plm_bom_revisions"
    repo UniboExPoc.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :version, :integer do
      default 1
      public? true
      description "BOM 版本号，ECO 应用变更时自增（只增不减）"
    end
    attribute :active, :boolean do
      default true
      public? true
      description "是否为当前生产版本（同一产品同一时间仅一个 active=true）"
    end
    attribute :change_description, :string do
      public? true
      description "版本变更描述（来自 ECO.note）"
    end
    attribute :effectivity_type, :atom do
      constraints one_of: [:date, :serial_range, :lot]
      default :date
      public? true
      description "生效类型（初期仅实现 date 模式）"
    end
  end

  relationships do
    belongs_to :eco, UniboExPoc.PLM.Eco do
      public? true
    end
  end

end
