# Workflow: field_service_lifecycle — 现场服务任务生命周期（创建→排期→执行→完成/取消）
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> schedule
#   create --> start_timer
#   create --> cancel
#   schedule --> start_timer
#   schedule --> cancel
#   start_timer --> stop_timer
#   start_timer --> add_material
#   start_timer --> fill_worksheet
#   start_timer --> sign
#   start_timer --> mark_done
#   start_timer --> cancel
#   stop_timer --> start_timer
#   stop_timer --> add_material
#   stop_timer --> fill_worksheet
#   stop_timer --> sign
#   stop_timer --> mark_done
#   stop_timer --> cancel
#   add_material --> add_material
#   add_material --> fill_worksheet
#   add_material --> sign
#   add_material --> stop_timer
#   add_material --> mark_done
#   add_material --> cancel
#   fill_worksheet --> sign
#   fill_worksheet --> add_material
#   fill_worksheet --> stop_timer
#   fill_worksheet --> mark_done
#   fill_worksheet --> cancel
#   sign --> mark_done
#   sign --> add_material
#   sign --> stop_timer
#   mark_done --> [*]
#   cancel --> [*]
# ```
defmodule UniboExPoc.Helpdesk.FieldServiceOrder do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Helpdesk,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.Helpdesk.FieldServiceOrder.Notifier]

  resource do
    description "现场服务工单/任务，从 Helpdesk 工单创建，支持多次上门、工时记录、物料使用、工作表填写"
  end

  postgres do
    table "helpdesk_field_service_orders"
    repo UniboExPoc.Repo
  end

  graphql do
    type :helpdesk_field_service_order

    queries do
      get :get_helpdesk_field_service_order, :read
      list :list_helpdesk_field_service_orders, :read
    end

    mutations do
      create :create_helpdesk_field_service_order, :create
      update :schedule_helpdesk_field_service_order, :schedule
      update :start_timer_helpdesk_field_service_order, :start_timer
      update :stop_timer_helpdesk_field_service_order, :stop_timer
      update :add_material_helpdesk_field_service_order, :add_material
      update :fill_worksheet_helpdesk_field_service_order, :fill_worksheet
      update :sign_helpdesk_field_service_order, :sign
      update :mark_done_helpdesk_field_service_order, :mark_done
      update :cancel_helpdesk_field_service_order, :cancel
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "任务标题（默认\"现场服务: {ticket.name}\"）"
    end
    attribute :description, :string do
      public? true
      description "继承自工单描述"
    end
    attribute :planned_date_begin, :utc_datetime do
      public? true
      description "计划开始时间（待调度员排期）"
    end
    attribute :planned_date_end, :utc_datetime do
      public? true
      description "计划结束时间"
    end
    attribute :fsm_done, :boolean do
      allow_nil? false
      default false
      public? true
      description "标记完成，触发库存扣减 + 开票"
    end
    attribute :allocated_hours, :decimal do
      public? true
      description "预分配工时（小时）"
    end
    attribute :priority, :atom do
      constraints one_of: [:low, :normal, :high, :urgent]
      default :normal
      public? true
      description "任务优先级"
    end
    attribute :date_deadline, :date do
      public? true
      description "截止日期"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :helpdesk_ticket, UniboExPoc.Helpdesk.HelpdeskTicket do
      public? true
    end
    belongs_to :project, UniboExPoc.Helpdesk.Project do
      public? true
    end
    belongs_to :partner, UniboExPoc.Helpdesk.Party do
      public? true
      source_attribute :partner_party_id
    end
    belongs_to :user, UniboExPoc.Helpdesk.Party do
      public? true
      source_attribute :user_party_id
    end
    belongs_to :stage, UniboExPoc.Helpdesk.FsmTaskStage do
      public? true
      allow_nil? false
    end
    belongs_to :worksheet_template, UniboExPoc.Helpdesk.WorksheetTemplate do
      public? true
    end
    many_to_many :tag_ids, UniboExPoc.Helpdesk.Tag do
      public? true
      through UniboExPoc.Helpdesk.FieldServiceOrderTagLink
    end
    has_many :assignments, UniboExPoc.Helpdesk.FieldServiceAssignment do
      public? true
      destination_attribute :service_order_id
    end
    has_many :materials, UniboExPoc.Helpdesk.FsmMaterialLine do
      public? true
      destination_attribute :service_order_id
    end
    has_many :timesheets, UniboExPoc.Helpdesk.FsmTimesheetEntry do
      public? true
      destination_attribute :service_order_id
    end
    has_many :worksheets, UniboExPoc.Helpdesk.Worksheet do
      public? true
      destination_attribute :service_order_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      description "R32: 从工单创建时自动继承客户信息、地址、描述、标签、负责人
同时递增工单的 field_service_task_count
"
      primary? true
      accept [:name, :description, :planned_date_begin, :planned_date_end, :allocated_hours, :priority, :date_deadline]
      argument :helpdesk_ticket_id, :uuid
      argument :project_id, :uuid
      argument :partner_id, :uuid
      argument :user_id, :uuid
      argument :stage_id, :uuid, allow_nil?: false
      argument :worksheet_template_id, :uuid
      change manage_relationship(:stage_id, :stage, type: :append, on_lookup: :relate)
      validate present(:name)
      # message: "任务标题必填"
      validate present(:stage)
      # message: "必须指定阶段"
      change UniboExPoc.Helpdesk.Changes.FieldServiceOrder.CreateCall3
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :schedule do
      description "R33: 调度排期，基于：
(a) 客户偏好时间窗
(b) 技术员资源可用性（日历）
(c) 技能匹配（执照、专业技能标签）
"
      primary? true
      accept [:planned_date_begin, :planned_date_end, :allocated_hours, :date_deadline]
      argument :user_id, :uuid
      argument :stage_id, :uuid
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :start_timer do
      description "启动计时器，自动设置 stage → in_progress"
      accept []
      argument :stage_id, :uuid, allow_nil?: false
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :stop_timer do
      description "停止计时器，记录本次工时"
      accept []
      change UniboExPoc.Helpdesk.Changes.FieldServiceOrder.StopTimerCall7
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :add_material do
      description "添加物料行（通过回调在 FsmMaterialLine 上创建）"
      accept []
      # skipped: validate state_guard :stage (incompatible with bulk update atomic path)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :fill_worksheet do
      description "填写工作表（通过回调在 Worksheet 上创建/更新）"
      accept []
      argument :worksheet_template_id, :uuid
      # skipped: validate present :worksheet_template (incompatible with bulk update atomic path)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :sign do
      description "客户签名确认"
      accept []
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :mark_done do
      description "设置 fsm_done=true + stage=done，触发库存扣减 + 发票创建
R35: on_field_service_task_done 检查 all_done?
若所有任务已完成则自动推进工单阶段到 Solved
"
      accept []
      argument :stage_id, :uuid, allow_nil?: false
      # skipped: validate compare :stage (incompatible with bulk update atomic path)
      change set_attribute(:fsm_done, true)
      change UniboExPoc.Helpdesk.Changes.FieldServiceOrder.MarkDoneCall4
      change UniboExPoc.Helpdesk.Changes.FieldServiceOrder.MarkDoneCall5
      change UniboExPoc.Helpdesk.Changes.FieldServiceOrder.MarkDoneCall6
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :cancel do
      description "取消任务"
      accept []
      argument :stage_id, :uuid, allow_nil?: false
      # skipped: validate state_guard :stage (incompatible with bulk update atomic path)
      change set_attribute(:fsm_done, false)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
  end

  identities do
    identity :unique_field_service_name, [:name, :helpdesk_ticket_id]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
