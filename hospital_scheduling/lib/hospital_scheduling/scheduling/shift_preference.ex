defmodule HospitalScheduling.Scheduling.ShiftPreference do
  use Ash.Resource,
    otp_app: :hospital_scheduling,
    domain: HospitalScheduling.Scheduling,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "护士个人排班偏好"
  end

  postgres do
    table "scheduling_shift_preferences"
    repo HospitalScheduling.Repo
  end

  graphql do
    type :scheduling_shift_preference

    queries do
      get :get_scheduling_shift_preference, :read
      list :list_scheduling_shift_preferences, :read
    end

    mutations do
      create :create_scheduling_shift_preference, :create
      update :update_scheduling_shift_preference, :update
      destroy :delete_scheduling_shift_preference, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :preferred_shift_tags, :string do
      public? true
      description "偏好班次标签"
    end
    attribute :unavailable_dates, :string do
      public? true
      description "不可排日期列表（本地业务日）"
    end
    attribute :max_night_shifts, :integer do
      public? true
      description "期望夜班上限"
    end
    attribute :notes, :string do
      public? true
      description "补充说明"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :employee, HospitalScheduling.Scheduling.Employee do
      public? true
      allow_nil? false
    end
    belongs_to :period, HospitalScheduling.Scheduling.SchedulingPeriod do
      public? true
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      description "Create Shift Preference via Create. doc_url: graphql://contract/scheduling/create_scheduling_shift_preference"
      primary? true
      accept [:period_id, :preferred_shift_tags, :unavailable_dates, :max_night_shifts, :notes]
      argument :employee_id, :uuid, allow_nil?: false
      change manage_relationship(:employee_id, :employee, type: :append, on_lookup: :relate)
    end
    update :update do
      description "Update Shift Preference via Update. doc_url: graphql://contract/scheduling/update_scheduling_shift_preference"
      primary? true
      accept [:preferred_shift_tags, :unavailable_dates, :max_night_shifts, :notes]
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
