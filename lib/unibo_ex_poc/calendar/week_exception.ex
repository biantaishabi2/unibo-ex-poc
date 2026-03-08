# Workflow: week_exception_manage_flow — 周例外管理
# ```mermaid
# stateDiagram-v2
#   [*] --> add
#   add --> remove
#   remove --> [*]
# ```
defmodule UniboV4.Calendar.WeekException do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Calendar,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "按周例外——在指定日期范围内用替代周模板覆盖默认周模板（对齐 OFBiz TechDataCalendarExcWeek）"
  end

  postgres do
    table "calendar_week_exceptions"
    repo UniboV4.Repo
  end

  graphql do
    type :calendar_week_exception

    queries do
      get :get_calendar_week_exception, :read
      list :list_calendar_week_exceptions, :read
    end

    mutations do
      create :create_add_calendar_week_exception, :add
      destroy :delete_remove_calendar_week_exception, :remove
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :start_date, :date do
      allow_nil? false
      public? true
      description "周例外生效开始日期（对齐 TechDataCalendarExcWeek.exception_date_start_time）"
    end
    attribute :end_date, :date do
      allow_nil? false
      public? true
      description "周例外生效结束日期"
    end
    attribute :description, :string do
      public? true
      description "说明（如\"春节调休周\"、\"项目冲刺周\"）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :work_schedule, UniboV4.Calendar.WorkSchedule do
      public? true
      allow_nil? false
    end
    belongs_to :override_week_template, UniboV4.Calendar.WeekTemplate do
      public? true
    end
    has_many :translations, UniboV4.Calendar.WeekExceptionTranslation, public?: true
  end

  actions do
    defaults [:read, :update]
    create :add do
      description "添加周例外"
      primary? true
      accept [:work_schedule_id, :start_date, :end_date, :description]
      argument :override_week_template_id, :uuid, allow_nil?: false
      argument :work_schedule_id, :uuid, allow_nil?: false
      change manage_relationship(:work_schedule_id, :work_schedule, type: :append, on_lookup: :relate)
      validate present(:work_schedule_id)
      validate present(:start_date)
      validate present(:end_date)
      change set_attribute(:id, expr(id))
    end
    destroy :remove do
      description "移除周例外"
      primary? true
      change set_attribute(:id, expr(id))
    end
  end

  validations do
    validate compare(:end_date, greater_than: :start_date)
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
