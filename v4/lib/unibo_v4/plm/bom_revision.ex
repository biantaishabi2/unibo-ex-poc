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
defmodule UniboV4.PLM.BomRevision do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.PLM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "plm_bom_revisions"
    repo UniboV4.Repo
  end

  graphql do
    type :plm_bom_revision

  end

  attributes do
    uuid_primary_key :id
    attribute :version, :integer do
      default 1
      public? true
    end
    attribute :active, :boolean do
      default true
      public? true
    end
    attribute :change_description, :string, public?: true
    attribute :effectivity_type, :atom do
      constraints one_of: [:date, :serial_range, :lot]
      default :date
      public? true
    end
  end

  relationships do
    belongs_to :eco, UniboV4.PLM.Eco do
      public? true
    end
  end

end
