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
defmodule UniboV4.Calendar.Calendar.CalendarEvent do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Calendar.Calendar,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Calendar.Calendar.CalendarEvent.Notifier]

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
    end
    attribute :description, :string, public?: true
    attribute :event_type, :atom do
      allow_nil? false
      constraints one_of: [:task, :meeting]
      public? true
    end
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:draft, :tentative, :confirmed, :cancelled]
      default :draft
      public? true
    end
    attribute :purpose, :string, public?: true
    attribute :scope, :atom do
      constraints one_of: [:private, :public, :internal]
      default :internal
      public? true
    end
    attribute :priority, :integer, public?: true
    attribute :show_as, :atom do
      constraints one_of: [:busy, :free, :tentative, :out_of_office]
      default :busy
      public? true
    end
    attribute :location, :string, public?: true
    attribute :start_datetime, :utc_datetime do
      allow_nil? false
      public? true
    end
    attribute :end_datetime, :utc_datetime do
      allow_nil? false
      public? true
    end
    attribute :actual_start, :utc_datetime, public?: true
    attribute :actual_end, :utc_datetime, public?: true
    attribute :send_notification, :boolean do
      default true
      public? true
    end
    attribute :ical_uid, :string, public?: true
    attribute :source_reference, :string, public?: true
    attribute :recurrence_rule, :string, public?: true
    attribute :all_day, :boolean do
      default false
      public? true
    end
    attribute :reminder_minutes, :integer, public?: true
    attribute :video_call_url, :string, public?: true
    attribute :color, :integer do
      default 0
      public? true
    end
    attribute :percent_complete, :integer, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :effective_duration
  end

  relationships do
    belongs_to :calendar, UniboV4.Calendar.Calendar.Calendar do
      public? true
    end
    belongs_to :work_schedule, UniboV4.Calendar.Calendar.WorkSchedule do
      public? true
    end
    has_many :attendees, UniboV4.Calendar.Calendar.Attendee do
      public? true
      destination_attribute :event_id
    end
    belongs_to :parent_event, UniboV4.Calendar.Calendar.CalendarEvent do
      public? true
    end
    has_many :child_events, UniboV4.Calendar.Calendar.CalendarEvent do
      public? true
      destination_attribute :parent_event_id
    end
    has_many :translations, UniboV4.Calendar.Calendar.CalendarEventTranslation, public?: true
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:title, :description, :event_type, :status, :purpose, :scope, :priority, :show_as, :location, :start_datetime, :end_datetime, :send_notification, :recurrence_rule, :all_day, :reminder_minutes, :video_call_url, :color, :percent_complete]
      validate present(:title)
      validate present(:start_datetime)
      validate present(:end_datetime)
      validate present(:event_type)
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
      accept [:title, :description, :status, :purpose, :scope, :priority, :show_as, :location, :start_datetime, :end_datetime, :send_notification, :recurrence_rule, :all_day, :reminder_minutes, :video_call_url, :color, :percent_complete]
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
    update :confirm do
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
    update :cancel do
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
    update :revert_to_draft do
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
    update :mark_tentative do
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

  validations do
    validate compare(:end_datetime, greater_than: :start_datetime)
  end

  identities do
    identity :unique_ical_uid, [:ical_uid]
  end

end
