# Workflow: calendar_event_lifecycle_flow — 日历事件创建、修改与确认流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> confirm
#   create --> cancel
#   create --> revert_to_draft
#   create --> mark_tentative
#   create --> destroy
#   update --> confirm
#   update --> cancel
#   update --> revert_to_draft
#   update --> mark_tentative
#   update --> destroy
#   confirm --> update
#   confirm --> cancel
#   confirm --> destroy
#   cancel --> destroy
#   revert_to_draft --> confirm
#   revert_to_draft --> cancel
#   revert_to_draft --> mark_tentative
#   revert_to_draft --> update
#   mark_tentative --> confirm
#   mark_tentative --> cancel
#   mark_tentative --> revert_to_draft
#   mark_tentative --> update
#   destroy --> [*]
# ```
defmodule UniboV4.Calendar.CalendarEvent do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Calendar,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource],
    notifiers: [UniboV4.Calendar.CalendarEvent.Notifier]

  resource do
    description "日历事件（任务/会议），支持重复规则、全天事件、提醒、视频会议链接"
  end

  postgres do
    table "calendar_events"
    repo UniboV4.Repo
  end

  graphql do
    type :calendar_calendar_event

    queries do
      get :get_calendar_calendar_event, :read
      list :list_calendar_calendar_events, :read
    end

    mutations do
      create :create_calendar_calendar_event, :create
      update :update_calendar_calendar_event, :update
      update :confirm_calendar_calendar_event, :confirm
      update :cancel_calendar_calendar_event, :cancel
      update :revert_to_draft_calendar_calendar_event, :revert_to_draft
      update :mark_tentative_calendar_calendar_event, :mark_tentative
      destroy :delete_calendar_calendar_event, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :title, :string do
      allow_nil? false
      public? true
      description "事件标题（对齐 WorkEffort.work_effort_name）"
    end
    attribute :description, :string do
      public? true
      description "事件描述（对齐 WorkEffort.description）"
    end
    attribute :event_type, :atom do
      allow_nil? false
      constraints one_of: [:task, :meeting]
      public? true
      description "事件类型（对齐 WorkEffort.work_effort_type_id，分界字段：Calendar 仅含 TASK/MEETING）"
    end
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:draft, :tentative, :confirmed, :cancelled]
      default :draft
      public? true
      description "事件状态（对齐 WorkEffort.current_status_id；P2-7：新增 tentative 状态）"
    end
    attribute :purpose, :string do
      public? true
      description "事件用途（对齐 WorkEffort.work_effort_purpose_type_id）"
    end
    attribute :scope, :atom do
      constraints one_of: [:private, :public, :internal]
      default :internal
      public? true
      description "可见范围（对齐 WorkEffort.scope_enum_id）"
    end
    attribute :priority, :integer do
      public? true
      description "优先级（对齐 WorkEffort.priority）"
    end
    attribute :show_as, :atom do
      constraints one_of: [:busy, :free, :tentative, :out_of_office]
      default :busy
      public? true
      description "显示方式（对齐 WorkEffort.show_as_enum_id）"
    end
    attribute :location, :string do
      public? true
      description "地点描述（对齐 WorkEffort.location_desc）"
    end
    attribute :start_datetime, :utc_datetime do
      allow_nil? false
      public? true
      description "开始时间（对齐 WorkEffort.estimated_start_date）"
    end
    attribute :end_datetime, :utc_datetime do
      allow_nil? false
      public? true
      description "结束时间（对齐 WorkEffort.estimated_completion_date）"
    end
    attribute :actual_start, :utc_datetime do
      public? true
      description "实际开始时间（对齐 WorkEffort.actual_start_date）"
    end
    attribute :actual_end, :utc_datetime do
      public? true
      description "实际结束时间（对齐 WorkEffort.actual_completion_date）"
    end
    attribute :send_notification, :boolean do
      default true
      public? true
      description "是否发送通知（对齐 WorkEffort.send_notification_email）"
    end
    attribute :ical_uid, :string do
      public? true
      description "iCal UID，用于日历同步（对齐 WorkEffort.universal_id）"
    end
    attribute :source_reference, :string do
      public? true
      description "外部来源引用（对齐 WorkEffort.source_reference_id）"
    end
    attribute :recurrence_rule, :string do
      public? true
      description "iCal RRULE 重复规则（如 FREQ=WEEKLY;BYDAY=MO）"
    end
    attribute :all_day, :boolean do
      default false
      public? true
      description "是否全天事件"
    end
    attribute :reminder_minutes, :integer do
      public? true
      description "提前提醒分钟数"
    end
    attribute :video_call_url, :string do
      public? true
      description "视频会议链接"
    end
    attribute :color, :integer do
      default 0
      public? true
      description "日历颜色索引"
    end
    attribute :percent_complete, :integer do
      public? true
      description "完成百分比（对齐 WorkEffort.percent_complete，仅任务类型使用）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  calculations do
    calculate :effective_duration, :float, expr(compute_effective_duration(start_datetime, end_datetime, work_schedule_id))
  end

  relationships do
    belongs_to :calendar, UniboV4.Calendar.Calendar do
      public? true
    end
    belongs_to :work_schedule, UniboV4.Calendar.WorkSchedule do
      public? true
    end
    has_many :attendees, UniboV4.Calendar.Attendee do
      public? true
      source_attribute :parent_event_id
      destination_attribute :event_id
    end
    belongs_to :parent_event, UniboV4.Calendar.CalendarEvent do
      public? true
    end
    has_many :child_events, UniboV4.Calendar.CalendarEvent do
      public? true
      source_attribute :parent_event_id
      destination_attribute :parent_event_id
    end
    has_many :translations, UniboV4.Calendar.CalendarEventTranslation, public?: true
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:title, :description, :event_type, :status, :purpose, :parent_event_id, :calendar_id, :work_schedule_id, :scope, :priority, :show_as, :location, :start_datetime, :end_datetime, :send_notification, :recurrence_rule, :all_day, :reminder_minutes, :video_call_url, :color, :percent_complete]
      validate present(:title)
      validate present(:start_datetime)
      validate present(:end_datetime)
      validate present(:event_type)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:title, :description, :status, :purpose, :scope, :priority, :show_as, :location, :start_datetime, :end_datetime, :send_notification, :recurrence_rule, :all_day, :reminder_minutes, :video_call_url, :color, :percent_complete, :calendar_id, :work_schedule_id]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :confirm do
      description "确认事件"
      accept []
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :cancel do
      description "取消事件"
      accept []
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :revert_to_draft do
      description "退回草稿状态（P2-7：原 tentative action 语义修正为 revert_to_draft）"
      accept []
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :mark_tentative do
      description "标记为暂定状态（P2-7：新增，对应 status enum 中的 tentative）"
      accept []
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  validations do
    validate compare(:end_datetime, greater_than: :start_datetime)
  end

  identities do
    identity :unique_ical_uid, [:ical_uid]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:attendees, :child_events]
  end

end
