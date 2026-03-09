# Workflow: calendar_exception_manage_flow — 日历例外管理
# ```mermaid
# stateDiagram-v2
#   [*] --> add
#   add --> remove
#   remove --> [*]
# ```
defmodule UniboExPoc.Calendar.CalendarException do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Calendar,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "日历例外日期（节假日、特殊工作安排），覆盖常规周模板"
  end

  postgres do
    table "calendar_exceptions"
    repo UniboExPoc.Repo
  end

  graphql do
    type :calendar_calendar_exception

    queries do
      get :get_calendar_calendar_exception, :read
      list :list_calendar_calendar_exceptions, :read
    end

    mutations do
      create :create_add_calendar_calendar_exception, :add
      destroy :delete_remove_calendar_calendar_exception, :remove
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :exception_date, :date do
      allow_nil? false
      public? true
      description "例外日期（对齐 TechDataCalendarExcDay.exception_date_start_time）"
    end
    attribute :exception_type, :atom do
      allow_nil? false
      constraints one_of: [:holiday, :special_working, :half_day, :overtime]
      public? true
      description "例外类型"
    end
    attribute :description, :string do
      public? true
      description "说明（如\"劳动节\"、\"调休工作日\"）（对齐 TechDataCalendarExcDay.description）"
    end
    attribute :exception_capacity, :float do
      public? true
      description "例外日容量（对齐 TechDataCalendarExcDay.exception_capacity）"
    end
    attribute :start_time, :string do
      public? true
      description "例外日开始时间"
    end
    attribute :end_time, :string do
      public? true
      description "例外日结束时间"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :work_schedule, UniboExPoc.Calendar.WorkSchedule do
      public? true
      allow_nil? false
    end
    has_many :translations, UniboExPoc.Calendar.CalendarExceptionTranslation, public?: true
  end

  actions do
    defaults [:read, :update]
    create :add do
      description "添加例外日期"
      primary? true
      accept [:work_schedule_id, :exception_date, :exception_type, :description, :exception_capacity, :start_time, :end_time]
      argument :work_schedule_id, :uuid, allow_nil?: false
      change manage_relationship(:work_schedule_id, :work_schedule, type: :append, on_lookup: :relate)
      validate present(:work_schedule_id)
      validate present(:exception_date)
      validate present(:exception_type)
      change set_attribute(:id, expr(id))
    end
    destroy :remove do
      description "移除例外日期"
      primary? true
      change set_attribute(:id, expr(id))
    end
  end

  identities do
    identity :unique_schedule_date, [:work_schedule_id, :exception_date]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
