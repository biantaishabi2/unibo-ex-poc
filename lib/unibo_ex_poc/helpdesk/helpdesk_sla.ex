# Workflow: sla_policy_management — SLA 策略管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> update
# ```
defmodule UniboExPoc.Helpdesk.HelpdeskSLA do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Helpdesk,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "SLA 策略定义，按条件匹配工单并设定时效要求"
  end

  postgres do
    table "helpdesk_slas"
    repo UniboExPoc.Repo
  end

  graphql do
    type :helpdesk_helpdesk_sla

    queries do
      get :get_helpdesk_helpdesk_sla, :read
      list :list_helpdesk_helpdesk_slas, :read
    end

    mutations do
      create :create_helpdesk_helpdesk_sla, :create
      update :update_helpdesk_helpdesk_sla, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "策略名称"
    end
    attribute :time_days, :integer do
      allow_nil? false
      default 0
      public? true
      description "时限天数"
    end
    attribute :time_hours, :decimal do
      allow_nil? false
      default 0.0
      public? true
      description "时限小时数"
    end
    attribute :minimum_priority, :atom do
      constraints one_of: [:low, :normal, :high, :urgent]
      public? true
      description "最低优先级门槛（匹配条件之一）"
    end
    attribute :active, :boolean do
      allow_nil? false
      default true
      public? true
      description "归档标记"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :team, UniboExPoc.Helpdesk.HelpdeskTeam do
      public? true
      allow_nil? false
    end
    belongs_to :reach_stage, UniboExPoc.Helpdesk.HelpdeskStage do
      public? true
      allow_nil? false
    end
    belongs_to :ticket_type, UniboExPoc.Helpdesk.HelpdeskTicketType do
      public? true
    end
    many_to_many :tag_ids, UniboExPoc.Helpdesk.HelpdeskTag do
      public? true
      through UniboExPoc.Helpdesk.HelpdeskSLATagLink
    end
    many_to_many :partner_ids, UniboExPoc.Helpdesk.Party do
      public? true
      through UniboExPoc.Helpdesk.HelpdeskSLAPartnerLink
      destination_attribute_on_join_resource :partner_party_id
    end
    many_to_many :exclude_stage_ids, UniboExPoc.Helpdesk.HelpdeskStage do
      public? true
      through UniboExPoc.Helpdesk.HelpdeskSLAExcludeStageLink
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :time_days, :time_hours, :minimum_priority]
      argument :team_id, :uuid, allow_nil?: false
      argument :reach_stage_id, :uuid, allow_nil?: false
      argument :ticket_type_id, :uuid
      change manage_relationship(:team_id, :team, type: :append, on_lookup: :relate)
      change manage_relationship(:reach_stage_id, :reach_stage, type: :append, on_lookup: :relate)
      validate present(:name)
      # message: "策略名称必填"
      validate present(:team)
      # message: "必须指定所属团队"
      validate present(:reach_stage)
      # message: "必须指定目标阶段"
      # validation: reach_stage_belongs_to_team — 目标阶段必须是团队已关联的阶段
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :time_days, :time_hours, :minimum_priority, :active]
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_sla_name_team, [:name, :team_id]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
