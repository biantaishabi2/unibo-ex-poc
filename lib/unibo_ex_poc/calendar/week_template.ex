# Workflow: week_template_maintain_flow — 周模板维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Calendar.WeekTemplate do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Calendar,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "每周时间模板，定义每天的开始时间和工作容量"
  end

  postgres do
    table "calendar_week_templates"
    repo UniboExPoc.Repo
  end

  graphql do
    type :calendar_week_template

    queries do
      get :get_calendar_week_template, :read
      list :list_calendar_week_templates, :read
    end

    mutations do
      create :create_calendar_week_template, :create
      update :update_calendar_week_template, :update
      destroy :delete_calendar_week_template, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "周模板名称（对齐 TechDataCalendarWeek.calendar_week_id + description）"
    end
    attribute :description, :string do
      public? true
      description "说明（对齐 TechDataCalendarWeek.description）"
    end
    attribute :monday_start, :string do
      public? true
      description "周一开始时间（对齐 TechDataCalendarWeek.monday_start_time）"
    end
    attribute :monday_capacity, :float do
      default 0.0
      public? true
      description "周一容量（对齐 TechDataCalendarWeek.monday_capacity）"
    end
    attribute :tuesday_start, :string do
      public? true
      description "周二开始时间"
    end
    attribute :tuesday_capacity, :float do
      default 0.0
      public? true
      description "周二容量"
    end
    attribute :wednesday_start, :string do
      public? true
      description "周三开始时间"
    end
    attribute :wednesday_capacity, :float do
      default 0.0
      public? true
      description "周三容量"
    end
    attribute :thursday_start, :string do
      public? true
      description "周四开始时间"
    end
    attribute :thursday_capacity, :float do
      default 0.0
      public? true
      description "周四容量"
    end
    attribute :friday_start, :string do
      public? true
      description "周五开始时间"
    end
    attribute :friday_capacity, :float do
      default 0.0
      public? true
      description "周五容量"
    end
    attribute :saturday_start, :string do
      public? true
      description "周六开始时间"
    end
    attribute :saturday_capacity, :float do
      default 0.0
      public? true
      description "周六容量"
    end
    attribute :sunday_start, :string do
      public? true
      description "周日开始时间"
    end
    attribute :sunday_capacity, :float do
      default 0.0
      public? true
      description "周日容量"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    has_many :work_schedules, UniboExPoc.Calendar.WorkSchedule do
      public? true
      destination_attribute :week_template_id
    end
    has_many :translations, UniboExPoc.Calendar.WeekTemplateTranslation, public?: true
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :description, :monday_start, :monday_capacity, :tuesday_start, :tuesday_capacity, :wednesday_start, :wednesday_capacity, :thursday_start, :thursday_capacity, :friday_start, :friday_capacity, :saturday_start, :saturday_capacity, :sunday_start, :sunday_capacity]
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :description, :monday_start, :monday_capacity, :tuesday_start, :tuesday_capacity, :wednesday_start, :wednesday_capacity, :thursday_start, :thursday_capacity, :friday_start, :friday_capacity, :saturday_start, :saturday_capacity, :sunday_start, :sunday_capacity]
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
    archive_related [:work_schedules]
  end

end
