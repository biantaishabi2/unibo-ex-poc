defmodule HospitalScheduling.Scheduling.ShiftType do
  use Ash.Resource,
    otp_app: :hospital_scheduling,
    domain: HospitalScheduling.Scheduling,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "班次类型定义（早班/中班/夜班等），是排班的基础维度"
  end

  postgres do
    table "scheduling_shift_types"
    repo HospitalScheduling.Repo
    identity_index_names unique_dept_shift_code: "idx_scheduling_shift_types_unique_dept_shift_code"
  end

  graphql do
    type :scheduling_shift_type

    queries do
      get :get_scheduling_shift_type, :read
      list :list_scheduling_shift_types, :read
    end

    mutations do
      create :create_scheduling_shift_type, :create
      update :update_scheduling_shift_type, :update
      destroy :delete_scheduling_shift_type, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :code, :string do
      allow_nil? false
      public? true
      description "班次编码，如 day, evening, night"
    end
    attribute :name, :string do
      allow_nil? false
      public? true
      description "班次名称，如\"白班\"、\"小夜\"、\"大夜\""
    end
    attribute :start_time, :string do
      allow_nil? false
      public? true
      description "班次开始时间，如 08:00"
    end
    attribute :end_time, :string do
      allow_nil? false
      public? true
      description "班次结束时间，如 16:00"
    end
    attribute :duration_hours, :decimal do
      allow_nil? false
      public? true
      description "时长（小时），跨午夜时 end < start"
    end
    attribute :is_night, :boolean do
      allow_nil? false
      default false
      public? true
      description "是否算夜班（影响夜班公平性约束）"
    end
    attribute :color, :string do
      public? true
      description "前端显示色，如"
    end
    attribute :sort_order, :integer do
      allow_nil? false
      default 0
      public? true
      description "排序权重"
    end
    attribute :enabled, :boolean do
      allow_nil? false
      default true
      public? true
      description "是否启用"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :department, HospitalScheduling.Scheduling.Department do
      public? true
      allow_nil? false
    end
    has_many :coverage_requirements, HospitalScheduling.Scheduling.CoverageRequirement do
      public? true
      destination_attribute :shift_type_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      description "Create Shift Type via Create. doc_url: graphql://contract/scheduling/create_scheduling_shift_type"
      primary? true
      accept [:code, :name, :start_time, :end_time, :duration_hours, :is_night, :color, :sort_order, :enabled]
      argument :department_id, :uuid, allow_nil?: false
      change manage_relationship(:department_id, :department, type: :append, on_lookup: :relate)
      validate present(:code)
      validate present(:name)
    end
    update :update do
      description "Update Shift Type via Update. doc_url: graphql://contract/scheduling/update_scheduling_shift_type"
      primary? true
      accept [:name, :start_time, :end_time, :duration_hours, :is_night, :color, :sort_order, :enabled]
      require_atomic? false
    end
  end

  identities do
    identity :unique_dept_shift_code, [:department_id, :code]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    belongs_to_actor :user, HospitalScheduling.Accounts.User, allow_nil?: true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:coverage_requirements]
  end

end
