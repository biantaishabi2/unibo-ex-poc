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
defmodule UniboV4.Calendar.Calendar.WorkSchedule do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Calendar.Calendar,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

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
    end
    attribute :description, :string, public?: true
    attribute :active, :boolean do
      default true
      public? true
    end
    attribute :timezone, :string do
      default "Asia/Shanghai"
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :week_template, UniboV4.Calendar.Calendar.WeekTemplate do
      public? true
    end
    has_many :exceptions, UniboV4.Calendar.Calendar.CalendarException do
      public? true
      destination_attribute :work_schedule_id
    end
    has_many :week_exceptions, UniboV4.Calendar.Calendar.WeekException do
      public? true
      destination_attribute :work_schedule_id
    end
    has_many :events, UniboV4.Calendar.Calendar.CalendarEvent do
      public? true
      destination_attribute :work_schedule_id
    end
    has_many :translations, UniboV4.Calendar.Calendar.WorkScheduleTranslation, public?: true
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :description, :active, :timezone]
      argument :week_template_id, :uuid
      validate present(:name)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :update do
      primary? true
      accept [:name, :description, :active, :timezone]
      argument :week_template_id, :uuid
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
    update :activate do
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
    update :deactivate do
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
  end

end
