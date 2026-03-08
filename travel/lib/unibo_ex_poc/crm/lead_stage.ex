# Workflow: lead_stage_management — 管道阶段管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> update
# ```
defmodule UniboExPoc.CRM.LeadStage do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.CRM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "商机管道阶段，支持团队级可见性控制和看板折叠"
  end

  postgres do
    table "crm_lead_stages"
    repo UniboExPoc.Repo
  end

  graphql do
    type :crm_lead_stage

    queries do
      get :get_crm_lead_stage, :read
      list :list_crm_lead_stages, :read
    end

    mutations do
      create :create_crm_lead_stage, :create
      update :update_crm_lead_stage, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "阶段名称（可翻译）"
    end
    attribute :sequence, :integer do
      allow_nil? false
      public? true
      description "排序权重，排序规则 ORDER BY sequence, name, id"
    end
    attribute :is_won, :boolean do
      default false
      public? true
      description "标记为赢单阶段，is_won=true 且 sequence 最高者为 win 的目标阶段"
    end
    attribute :fold, :boolean do
      default false
      public? true
      description "看板中无记录时是否折叠"
    end
    attribute :probability, :decimal do
      public? true
      description "该阶段的默认概率"
    end
    attribute :requirements, :string do
      public? true
      description "阶段推进指引(tooltip)，仅作提示，不做硬约束"
    end
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :team, UniboExPoc.CRM.SalesTeam do
      public? true
    end
    has_many :leads, UniboExPoc.CRM.Lead do
      public? true
      source_attribute :team_id
      destination_attribute :stage_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :sequence, :is_won, :fold, :probability, :requirements, :description]
      argument :team_id, :uuid
      validate present(:name)
      validate present(:sequence)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :sequence, :is_won, :fold, :probability, :requirements, :description]
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
