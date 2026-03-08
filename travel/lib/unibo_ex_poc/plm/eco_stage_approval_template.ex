# Workflow: eco_approval_template_maintain_flow — 审批模板维护流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.PLM.EcoStageApprovalTemplate do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.PLM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "阶段审批模板，定义进入该阶段时需自动创建的审批记录"
  end

  postgres do
    table "plm_eco_stage_approval_templates"
    repo UniboExPoc.Repo
  end

  graphql do
    type :plm_eco_stage_approval_template

    mutations do
      create :create_plm_eco_stage_approval_template, :create
      update :update_plm_eco_stage_approval_template, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :role, :string do
      allow_nil? false
      public? true
      description "审批角色（工程经理 / 质量经理等）"
    end
    attribute :approver_id, :uuid do
      public? true
      description "默认审批人"
    end
    attribute :approval_type, :atom do
      constraints one_of: [:required, :optional, :comment]
      default :required
      public? true
      description "审批类型：required=必须 / optional=可选 / comment=仅评论"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :stage, UniboExPoc.PLM.EcoStage do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:role, :approver_id, :approval_type]
      argument :stage_id, :uuid, allow_nil?: false
      change manage_relationship(:stage_id, :stage, type: :append, on_lookup: :relate)
      validate present(:role)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:role, :approver_id, :approval_type]
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
