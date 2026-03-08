# Workflow: eco_stage_maintain_flow — ECO 阶段维护流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.PLM.EcoStage do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.PLM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "ECO 阶段，定义 Kanban 看板列及审批模板"
  end

  postgres do
    table "plm_eco_stages"
    repo UniboV4.Repo
  end

  graphql do
    type :plm_eco_stage

    queries do
      get :get_plm_eco_stage, :read
      list :list_plm_eco_stages, :read
    end

    mutations do
      create :create_plm_eco_stage, :create
      update :update_plm_eco_stage, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "阶段名称"
    end
    attribute :sequence, :integer do
      default 10
      public? true
      description "排序（决定 Kanban 列顺序）"
    end
    attribute :folded, :boolean do
      default false
      public? true
      description "在 Kanban 中是否折叠"
    end
    attribute :allow_apply, :boolean do
      default false
      public? true
      description "是否允许应用变更到生产 BOM"
    end
    attribute :is_final, :boolean do
      default false
      public? true
      description "是否为终态阶段"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    many_to_many :type_ids, UniboV4.PLM.EcoType do
      public? true
      through UniboV4.PLM.EcoTypeStageLink
    end
    has_many :approval_template_ids, UniboV4.PLM.EcoStageApprovalTemplate do
      public? true
      destination_attribute :stage_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :sequence, :folded, :allow_apply, :is_final]
      argument :approval_template_ids, {:array, :map}, default: []
      change manage_relationship(:approval_template_ids, :approval_template_ids, type: :create)
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :sequence, :folded, :allow_apply, :is_final]
      argument :approval_template_ids, {:array, :map}, default: []
      change manage_relationship(:approval_template_ids, :approval_template_ids, on_lookup: :relate, on_no_match: :create, on_match: :update)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_eco_stage_name, [:name]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
