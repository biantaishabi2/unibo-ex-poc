# Workflow: team_management — 服务团队管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> update
# ```
defmodule UniboExPoc.Helpdesk.HelpdeskTeam do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Helpdesk,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "服务团队，管理工单分配策略、功能开关和 SLA 策略"
  end

  postgres do
    table "helpdesk_teams"
    repo UniboExPoc.Repo
  end

  graphql do
    type :helpdesk_helpdesk_team

    queries do
      get :get_helpdesk_helpdesk_team, :read
      list :list_helpdesk_helpdesk_teams, :read
    end

    mutations do
      create :create_helpdesk_helpdesk_team, :create
      update :update_helpdesk_helpdesk_team, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "团队名称"
    end
    attribute :description, :string do
      public? true
      description "团队描述"
    end
    attribute :alias_email, :string do
      public? true
      description "邮件别名，用于邮件转工单"
    end
    attribute :assignment_method, :atom do
      allow_nil? false
      constraints one_of: [:manual, :random, :balanced]
      default :manual
      public? true
      description "分配算法：
manual — 不自动分配，user_id 保持 nil 直到手动指定
random — 从可用成员中随机选一人（排除当日请假人员）
balanced — 选择当前未关闭工单数量最少的可用成员
"
    end
    attribute :auto_assignment, :boolean do
      allow_nil? false
      default true
      public? true
      description "是否启用自动分配"
    end
    attribute :color, :integer do
      allow_nil? false
      default 0
      public? true
      description "Kanban 颜色索引"
    end
    attribute :active, :boolean do
      allow_nil? false
      default true
      public? true
      description "归档标记"
    end
    attribute :use_sla, :boolean do
      allow_nil? false
      default false
      public? true
      description "启用 SLA 策略"
    end
    attribute :use_website_form, :boolean do
      allow_nil? false
      default false
      public? true
      description "启用网站表单渠道"
    end
    attribute :use_customer_portal, :boolean do
      allow_nil? false
      default false
      public? true
      description "启用客户门户"
    end
    attribute :use_timesheet, :boolean do
      allow_nil? false
      default false
      public? true
      description "启用工时追踪"
    end
    attribute :use_field_service, :boolean do
      allow_nil? false
      default false
      public? true
      description "启用现场服务集成"
    end
    attribute :use_customer_rating, :boolean do
      allow_nil? false
      default false
      public? true
      description "启用客户满意度评分"
    end
    attribute :use_knowledge_base, :boolean do
      allow_nil? false
      default false
      public? true
      description "启用知识库"
    end
    attribute :resource_calendar_id, :integer do
      public? true
      description "关联工作日历（用于 SLA 工时计算，仅计入工作日历定义的工作时段）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :tickets, UniboExPoc.Helpdesk.HelpdeskTicket do
      public? true
      destination_attribute :team_id
    end
    has_many :sla_policies, UniboExPoc.Helpdesk.HelpdeskSLA do
      public? true
      destination_attribute :team_id
    end
    many_to_many :members, UniboExPoc.Helpdesk.Employee do
      public? true
      through UniboExPoc.Helpdesk.HelpdeskTeamMemberLink
    end
    many_to_many :stage_ids, UniboExPoc.Helpdesk.HelpdeskStage do
      public? true
      through UniboExPoc.Helpdesk.HelpdeskTeamStageLink
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :description, :alias_email, :assignment_method, :auto_assignment, :use_sla, :use_website_form, :use_customer_portal, :use_timesheet, :use_field_service, :use_customer_rating, :use_knowledge_base, :resource_calendar_id]
      validate present(:name)
      # message: "团队名称必填"
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :description, :alias_email, :assignment_method, :auto_assignment, :active, :use_sla, :use_website_form, :use_customer_portal, :use_timesheet, :use_field_service, :use_customer_rating, :use_knowledge_base, :resource_calendar_id]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_team_name, [:name]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
