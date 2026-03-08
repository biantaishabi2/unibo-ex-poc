# Workflow: work_schedule_lifecycle_flow — 工作日历维护流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> activate
#   create --> deactivate
#   create --> destroy
#   update --> activate
#   update --> deactivate
#   update --> destroy
#   activate --> update
#   activate --> deactivate
#   deactivate --> activate
#   deactivate --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Calendar.WorkSchedule do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Calendar,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "工作日历模板，定义工作时间规则（用于 HR/Manufacturing 排班）"
  end

  postgres do
    table "calendar_work_schedules"
    repo UniboV4.Repo
  end

  graphql do
    type :calendar_work_schedule

    queries do
      get :get_calendar_work_schedule, :read
      list :list_calendar_work_schedules, :read
    end

    mutations do
      create :create_calendar_work_schedule, :create
      update :update_calendar_work_schedule, :update
      update :activate_calendar_work_schedule, :activate
      update :deactivate_calendar_work_schedule, :deactivate
      destroy :delete_calendar_work_schedule, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "日历名称（对齐 TechDataCalendar.calendar_id + description）"
    end
    attribute :description, :string do
      public? true
      description "日历说明（对齐 TechDataCalendar.description）"
    end
    attribute :active, :boolean do
      default true
      public? true
      description "是否启用"
    end
    attribute :timezone, :string do
      default "Asia/Shanghai"
      public? true
      description "时区"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :week_template, UniboV4.Calendar.WeekTemplate do
      public? true
    end
    has_many :exceptions, UniboV4.Calendar.CalendarException do
      public? true
      source_attribute :week_template_id
      destination_attribute :work_schedule_id
    end
    has_many :week_exceptions, UniboV4.Calendar.WeekException do
      public? true
      source_attribute :week_template_id
      destination_attribute :work_schedule_id
    end
    has_many :events, UniboV4.Calendar.CalendarEvent do
      public? true
      source_attribute :week_template_id
      destination_attribute :work_schedule_id
    end
    has_many :translations, UniboV4.Calendar.WorkScheduleTranslation, public?: true
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :description, :active, :timezone]
      argument :week_template_id, :uuid
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :description, :active, :timezone]
      argument :week_template_id, :uuid
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :activate do
      description "启用日历"
      accept []
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :deactivate do
      description "停用日历"
      accept []
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:exceptions, :week_exceptions, :events]
  end

end
