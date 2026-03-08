defmodule UniboV4.Ofbiz.WorkEffort.WorkEffortEventReminder do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.WorkEffort,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "work_effort_event_reminders"
    repo UniboV4.Repo
  end

  graphql do
    type :work_effort_work_effort_event_reminder

    queries do
      get :get_work_effort_work_effort_event_reminder, :read
      list :list_work_effort_work_effort_event_reminders, :read
    end

    mutations do
      create :create_work_effort_work_effort_event_reminder, :create
      update :update_work_effort_work_effort_event_reminder, :update
      destroy :delete_work_effort_work_effort_event_reminder, :destroy
    end

  end

  attributes do
    attribute :sequence_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :reminder_date_time, :utc_datetime, public?: true
    attribute :repeat_count, :integer, public?: true
    attribute :repeat_interval, :integer do
      public? true
      description "提醒重复之间的毫秒间隔"
    end
    attribute :current_count, :integer, public?: true
    attribute :reminder_offset, :integer do
      public? true
      description "从事件到激活提醒的毫秒偏移"
    end
    attribute :locale_id, :string, public?: true
    attribute :time_zone_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :work_effort, UniboV4.Ofbiz.WorkEffort.WorkEffort do
      public? true
      attribute_type :string
    end
    belongs_to :contact_mech, UniboV4.Ofbiz.WorkEffort.ContactMech do
      public? true
      attribute_type :string
    end
    belongs_to :party, UniboV4.Ofbiz.WorkEffort.Party do
      public? true
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
