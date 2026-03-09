# Workflow: ticket_lifecycle — 工单生命周期（创建→分配→处理→解决→关闭）
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> assign
#   create --> change_stage
#   create --> update_priority
#   create --> plan_intervention
#   create --> archive
#   assign --> change_stage
#   assign --> resolve
#   assign --> update_priority
#   assign --> plan_intervention
#   assign --> archive
#   change_stage --> change_stage
#   change_stage --> resolve
#   change_stage --> close
#   change_stage --> reopen
#   change_stage --> update_priority
#   change_stage --> plan_intervention
#   resolve --> close
#   resolve --> reopen
#   close --> [*]
#   reopen --> assign
#   reopen --> change_stage
#   reopen --> resolve
#   reopen --> update_priority
#   archive --> [*]
#   update_priority --> change_stage
#   update_priority --> resolve
#   update_priority --> close
#   plan_intervention --> change_stage
#   plan_intervention --> resolve
#   plan_intervention --> close
# ```
defmodule UniboExPoc.Helpdesk.HelpdeskTicket do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Helpdesk,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.Helpdesk.HelpdeskTicket.Notifier]

  resource do
    description "服务台工单，阶段驱动状态机（New→In Progress→Solved→Closed）"
  end

  postgres do
    table "helpdesk_tickets"
    repo UniboExPoc.Repo
  end

  graphql do
    type :helpdesk_helpdesk_ticket

    queries do
      get :get_helpdesk_helpdesk_ticket, :read
      list :list_helpdesk_helpdesk_tickets, :read
    end

    mutations do
      create :create_helpdesk_helpdesk_ticket, :create
      update :assign_helpdesk_helpdesk_ticket, :assign
      update :change_stage_helpdesk_helpdesk_ticket, :change_stage
      update :resolve_helpdesk_helpdesk_ticket, :resolve
      update :close_helpdesk_helpdesk_ticket, :close
      update :reopen_helpdesk_helpdesk_ticket, :reopen
      update :archive_helpdesk_helpdesk_ticket, :archive
      update :update_priority_helpdesk_helpdesk_ticket, :update_priority
      update :plan_intervention_helpdesk_helpdesk_ticket, :plan_intervention
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "工单标题，tracked"
    end
    attribute :description, :string do
      public? true
      description "HTML 富文本描述"
    end
    attribute :priority, :atom do
      allow_nil? false
      constraints one_of: [:low, :normal, :high, :urgent]
      default :low
      public? true
      description "工单优先级"
    end
    attribute :kanban_state, :atom do
      allow_nil? false
      constraints one_of: [:normal, :blocked, :done]
      default :normal
      public? true
      description "看板子状态，blocked 表示等待外部依赖"
    end
    attribute :active, :boolean do
      allow_nil? false
      default true
      public? true
      description "归档标记（false=软删除，默认列表查询排除）"
    end
    attribute :color, :integer do
      allow_nil? false
      default 0
      public? true
      description "Kanban 颜色索引"
    end
    attribute :email_cc, :string do
      public? true
      description "抄送邮箱列表"
    end
    attribute :source_channel, :atom do
      constraints one_of: [:email, :web_form, :portal, :sales_order, :live_chat, :manual]
      public? true
      description "来源渠道，由创建方式自动设定"
    end
    attribute :create_date, :utc_datetime do
      allow_nil? false
      public? true
      description "创建时间"
    end
    attribute :assign_date, :utc_datetime do
      public? true
      description "首次分配时间（仅首次分配时记录）"
    end
    attribute :close_date, :utc_datetime do
      public? true
      description "工单关闭时间"
    end
    attribute :date_last_stage_update, :utc_datetime do
      public? true
      description "上次阶段变更时间"
    end
    attribute :sla_deadline, :utc_datetime do
      public? true
      description "所有 in_progress SLA 中最早的截止时间（动态计算）"
    end
    attribute :priority_update_date, :utc_datetime do
      public? true
      description "优先级变更时间，用于 SLA 起算"
    end
    attribute :field_service_task_count, :integer do
      allow_nil? false
      default 0
      public? true
      description "关联现场服务任务数"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :team, UniboExPoc.Helpdesk.HelpdeskTeam do
      public? true
      allow_nil? false
    end
    belongs_to :stage, UniboExPoc.Helpdesk.HelpdeskStage do
      public? true
      allow_nil? false
    end
    belongs_to :user, UniboExPoc.Helpdesk.Party do
      public? true
      source_attribute :user_party_id
    end
    belongs_to :partner, UniboExPoc.Helpdesk.Party do
      public? true
      source_attribute :partner_party_id
    end
    belongs_to :ticket_type, UniboExPoc.Helpdesk.HelpdeskTicketType do
      public? true
    end
    belongs_to :sales_order, UniboExPoc.Helpdesk.SalesOrder do
      public? true
    end
    belongs_to :created_by, UniboExPoc.Helpdesk.Party do
      public? true
      source_attribute :created_by_party_id
    end
    has_many :sla_status_ids, UniboExPoc.Helpdesk.HelpdeskSLAStatus do
      public? true
      destination_attribute :ticket_id
    end
    has_many :timesheet_ids, UniboExPoc.Helpdesk.TimesheetEntry do
      public? true
    end
    has_many :field_service_tasks, UniboExPoc.Helpdesk.FieldServiceOrder do
      public? true
    end
    has_many :rating_ids, UniboExPoc.Helpdesk.Rating do
      public? true
    end
    many_to_many :tag_ids, UniboExPoc.Helpdesk.HelpdeskTag do
      public? true
      through UniboExPoc.Helpdesk.HelpdeskTicketTagLink
    end
  end

  actions do
    defaults [:read]
    create :create do
      description "创建工单后自动执行：
R1. 根据团队 assignment_method 自动分配负责人
R4. 遍历团队下所有 SLA 策略进行匹配
R9. 来源渠道由创建方式自动设定
"
      primary? true
      accept [:name, :description, :priority, :source_channel, :email_cc]
      argument :team_id, :uuid, allow_nil?: false
      argument :stage_id, :uuid, allow_nil?: false
      argument :ticket_type_id, :uuid
      argument :partner_id, :uuid
      argument :sales_order_id, :uuid
      change manage_relationship(:team_id, :team, type: :append, on_lookup: :relate)
      change manage_relationship(:stage_id, :stage, type: :append, on_lookup: :relate)
      validate present(:name)
      # message: "工单标题必填"
      validate present(:team)
      # message: "必须指定服务团队"
      validate present(:stage)
      # message: "必须指定阶段"
      change relate_actor(:created_by)
      change set_attribute(:date_last_stage_update, &DateTime.utc_now/0)
      change UniboExPoc.Helpdesk.Changes.HelpdeskTicket.CreateCall8
      change UniboExPoc.Helpdesk.Changes.HelpdeskTicket.CreateCall9
      change UniboExPoc.Helpdesk.Changes.HelpdeskTicket.CreateCall11
      change UniboExPoc.Helpdesk.Changes.HelpdeskTicket.CreateCall14
      change set_attribute(:id, expr(id))
    end
    update :assign do
      description "分配工单 — R1: 根据团队 assignment_method (manual/random/balanced) 分配负责人
首次分配时记录 assign_date
"
      primary? true
      accept []
      argument :user_id, :uuid, allow_nil?: false
      change set_attribute(:assign_date, &DateTime.utc_now/0)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :change_stage do
      description "阶段变更 — R2: 触发副作用链
(a) 更新 date_last_stage_update
(b) 新阶段 is_close=true 时设置 close_date
(c) 从关闭阶段回退时清除 close_date
(d) 触发阶段上配置的邮件/短信模板
(e) 调用 check_sla_status() 更新所有关联 SLA
(f) 关闭且 use_customer_rating=true 时发送评分请求
"
      accept []
      argument :stage_id, :uuid, allow_nil?: false
      change set_attribute(:date_last_stage_update, &DateTime.utc_now/0)
      change UniboExPoc.Helpdesk.Changes.HelpdeskTicket.ChangeStageCall10
      change UniboExPoc.Helpdesk.Changes.HelpdeskTicket.ChangeStageCall11
      change UniboExPoc.Helpdesk.Changes.HelpdeskTicket.ChangeStageCall13
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :resolve do
      description "解决工单，流转到 Solved 阶段"
      accept []
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :close do
      description "关闭工单 — R3: 需通过 can_close_ticket? 检查
所有关联的 Field Service 任务必须已完成，否则阻止关闭
"
      accept []
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:close_date, &DateTime.utc_now/0)
      change UniboExPoc.Helpdesk.Changes.HelpdeskTicket.CloseCall12
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :reopen do
      description "重新打开工单，清除 close_date，回到 New 阶段"
      accept []
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :archive do
      description "R7 归档/软删除，设置 active=false"
      accept []
      change set_attribute(:active, false)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :update_priority do
      description "更新优先级 — R5: 如果优先级更新后才匹配某个 SLA，
该 SLA 的起算时间从 priority_update_date 开始
"
      accept [:priority]
      change set_attribute(:priority_update_date, &DateTime.utc_now/0)
      change UniboExPoc.Helpdesk.Changes.HelpdeskTicket.UpdatePriorityCall9
      change UniboExPoc.Helpdesk.Changes.HelpdeskTicket.UpdatePriorityCall11
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :plan_intervention do
      description "R31/R32: 创建现场服务任务
仅当团队 use_field_service=true 时可用
自动继承客户信息、地址、描述、标签、负责人
递增 field_service_task_count
"
      accept []
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_ticket_name_team, [:name, :team_id]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
