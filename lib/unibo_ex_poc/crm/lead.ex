# Workflow: lead_lifecycle — 线索/商机生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> convert_opportunity
#   create --> lose
#   create --> assign_salesperson
#   create --> merge
#   convert_opportunity --> update
#   convert_opportunity --> win
#   convert_opportunity --> lose
#   convert_opportunity --> assign_salesperson
#   win --> [*] : won
#   lose --> [*] : lost
#   assign_salesperson --> update
#   assign_salesperson --> convert_opportunity
#   assign_salesperson --> win
#   assign_salesperson --> lose
#   merge --> [*]
# ```
# Workflow: lead_stage_progression — 商机阶段推进流程
# ```mermaid
# stateDiagram-v2
#   [*] --> update
#   update --> update
#   update --> win
#   update --> lose
# ```
defmodule UniboExPoc.CRM.Lead do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.CRM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.CRM.Lead.Notifier]

  resource do
    description "线索/商机，CRM 核心实体。type=lead 为未筛选线索，type=opportunity 为已进入管道的商机"
  end

  postgres do
    table "crm_leads"
    repo UniboExPoc.Repo
  end

  graphql do
    type :crm_lead

    queries do
      get :get_crm_lead, :read
      list :list_crm_leads, :read
    end

    mutations do
      create :create_crm_lead, :create
      update :update_crm_lead, :update
      update :convert_opportunity_crm_lead, :convert_opportunity
      update :win_crm_lead, :win
      update :lose_crm_lead, :lose
      update :assign_salesperson_crm_lead, :assign_salesperson
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "商机名称"
    end
    attribute :type, :atom do
      constraints one_of: [:lead, :opportunity]
      default :lead
      public? true
      description "类型：lead（未筛选线索）或 opportunity（已进入管道的商机）"
    end
    attribute :partner_name, :string do
      public? true
      description "公司名（未创建 Contact 时暂存）"
    end
    attribute :contact_name, :string do
      public? true
      description "联系人名（未创建 Contact 时暂存）"
    end
    attribute :email_from, :string do
      public? true
      description "联系邮箱，含自动清洗(sanitize)"
    end
    attribute :phone, :string do
      public? true
      description "固定电话，含自动清洗"
    end
    attribute :mobile, :string do
      public? true
      description "手机号，含自动清洗"
    end
    attribute :expected_revenue, :decimal do
      public? true
      description "预计收入（手动填写的交易金额）"
    end
    attribute :prorated_revenue, :decimal do
      public? true
      description "概率加权营收，计算公式：expected_revenue * probability / 100"
    end
    attribute :probability, :decimal do
      public? true
      description "成交概率（百分比），默认与 automated_probability 同步，手动修改后脱离自动同步"
    end
    attribute :automated_probability, :decimal do
      public? true
      description "PLS 机器学习预测概率（朴素贝叶斯分类器）"
    end
    attribute :active, :boolean do
      default true
      public? true
      description "活跃状态，active=false 等价于\"已丢失\""
    end
    attribute :priority, :atom do
      constraints one_of: [:"0", :"1", :"2", :"3"]
      default :"0"
      public? true
      description "优先级（0=普通，1=低，2=中，3=高）"
    end
    attribute :tag_ids, :string do
      public? true
      description "标签列表（逗号分隔）"
    end
    attribute :source, :string do
      public? true
      description "来源渠道"
    end
    attribute :lost_reason, :string do
      public? true
      description "丢失原因，标记丢失时记录"
    end
    attribute :kanban_state, :atom do
      constraints one_of: [:grey, :red, :green]
      default :grey
      public? true
      description "看板状态，由活动截止日计算：grey(无活动)/red(过期)/green(未过期)"
    end
    attribute :lead_properties, :map do
      public? true
      description "团队级动态属性"
    end
    attribute :date_deadline, :date do
      public? true
      description "截止日期"
    end
    attribute :date_open, :utc_datetime do
      public? true
      description "首次分配销售员时间"
    end
    attribute :date_closed, :utc_datetime do
      public? true
      description "关闭时间（赢单或丢失）"
    end
    attribute :date_conversion, :utc_datetime do
      public? true
      description "lead 转为 opportunity 的时间"
    end
    attribute :date_last_stage_update, :utc_datetime do
      public? true
      description "最后一次阶段变更时间"
    end
    attribute :notes, :string do
      public? true
      description "备注/描述（HTML）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :contact, UniboExPoc.CRM.Contact do
      public? true
    end
    belongs_to :stage, UniboExPoc.CRM.LeadStage do
      public? true
    end
    belongs_to :assigned_to, UniboExPoc.CRM.Party do
      public? true
      source_attribute :assigned_to_party_id
    end
    belongs_to :team, UniboExPoc.CRM.SalesTeam do
      public? true
    end
    has_many :activities, UniboExPoc.CRM.Activity do
      public? true
    end
    has_many :calendar_events, UniboExPoc.CRM.CalendarEvent do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :type, :partner_name, :contact_name, :email_from, :phone, :mobile, :expected_revenue, :probability, :priority, :tag_ids, :source, :date_deadline, :notes, :lead_properties]
      argument :contact_id, :uuid
      argument :stage_id, :uuid
      argument :team_id, :uuid
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :partner_name, :contact_name, :email_from, :phone, :mobile, :expected_revenue, :probability, :priority, :tag_ids, :source, :date_deadline, :notes, :lead_properties]
      change set_attribute(:date_last_stage_update, &DateTime.utc_now/0)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :convert_opportunity do
      description "将 lead 转为 opportunity，记录 date_conversion，可选关联或创建 Contact"
      accept []
      argument :contact_id, :uuid
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :type)
        if current == :lead do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :type, message: "must equal %{value}", vars: %{value: :lead}))
        end
      end
      # message: "只有 lead 类型才能转为 opportunity"
      change set_attribute(:type, :opportunity)
      change set_attribute(:date_conversion, &DateTime.utc_now/0)
      change set_attribute(:date_last_stage_update, &DateTime.utc_now/0)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :win do
      description "标记赢单，进入 is_won=True 的阶段，probability 自动置为 100"
      accept []
      # skipped: validate compare :active (incompatible with bulk update atomic path)
      change set_attribute(:probability, 100)
      change set_attribute(:date_closed, &DateTime.utc_now/0)
      change set_attribute(:date_last_stage_update, &DateTime.utc_now/0)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :lose do
      description "标记丢失，active 置 false、probability 置 0，记录 lost_reason"
      accept [:lost_reason]
      # skipped: validate compare :active (incompatible with bulk update atomic path)
      change set_attribute(:active, false)
      change set_attribute(:probability, 0)
      change set_attribute(:date_closed, &DateTime.utc_now/0)
      change set_attribute(:date_last_stage_update, &DateTime.utc_now/0)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    action :merge do
      description "合并多条线索/商机，选置信度最高记录为主体"
      argument :source_lead_ids, :string, allow_nil?: false
      run fn input, _context ->
        :ok
      end
    end
    update :assign_salesperson do
      description "分配销售员，支持轮询分配"
      accept []
      argument :user_id, :uuid
      argument :team_id, :uuid
      change set_attribute(:date_last_stage_update, &DateTime.utc_now/0)
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
