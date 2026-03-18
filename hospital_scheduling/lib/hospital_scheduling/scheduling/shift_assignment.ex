defmodule HospitalScheduling.Scheduling.ShiftAssignment do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: HospitalScheduling.Scheduling,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource],
    notifiers: [Ash.Notifier.PubSub]

  resource do
    description "把某个覆盖需求分配给具体护士和时段"
  end

  postgres do
    table "scheduling_shift_assignments"
    repo HospitalScheduling.Repo
    identity_index_names unique_period_employee_start: "idx_scheduling_shift_assignments_unique_period_employee_start"
    identity_index_names unique_version_req_employee_start: "idx_scheduling_shift_assignments_unique_version_req_em_834b770a"
  end

  graphql do
    type :scheduling_shift_assignment

    queries do
      get :get_scheduling_shift_assignment, :read
      list :list_scheduling_shift_assignments, :read
    end

    mutations do
      create :create_scheduling_shift_assignment, :create
      update :update_scheduling_shift_assignment, :update
      update :lock_scheduling_shift_assignment, :lock
      update :unlock_scheduling_shift_assignment, :unlock
      destroy :delete_scheduling_shift_assignment, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :starts_at, :utc_datetime do
      allow_nil? false
      public? true
      description "开始时间（UTC）"
    end
    attribute :ends_at, :utc_datetime do
      allow_nil? false
      public? true
      description "结束时间（UTC）"
    end
    attribute :source, :atom do
      allow_nil? false
      constraints one_of: [:auto, :manual, :swapped, :copied]
      default :auto
      public? true
      description "分配来源（copied = 从上一期复制）"
    end
    attribute :is_locked, :boolean do
      allow_nil? false
      default false
      public? true
      description "锁定后重排不动"
    end
    attribute :notes, :string do
      public? true
      description "人工调班说明"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :period, HospitalScheduling.Scheduling.SchedulingPeriod do
      public? true
      allow_nil? false
    end
    belongs_to :requirement, HospitalScheduling.Scheduling.CoverageRequirement do
      public? true
      allow_nil? false
    end
    belongs_to :version, HospitalScheduling.Scheduling.ScheduleVersion do
      public? true
      allow_nil? false
    end
    belongs_to :employee, HospitalScheduling.Scheduling.Employee do
      public? true
      allow_nil? false
    end
    belongs_to :baseline_run, HospitalScheduling.Scheduling.SolverRun do
      public? true
    end
    has_many :constraint_violations, HospitalScheduling.Scheduling.ConstraintViolation do
      public? true
      destination_attribute :assignment_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      description "Create Shift Assignment via Create. doc_url: graphql://contract/scheduling/create_scheduling_shift_assignment"
      primary? true
      accept [:starts_at, :ends_at, :source, :is_locked, :notes]
      argument :period_id, :uuid, allow_nil?: false
      change manage_relationship(:period_id, :period, type: :append, on_lookup: :relate)
      argument :requirement_id, :uuid, allow_nil?: false
      change manage_relationship(:requirement_id, :requirement, type: :append, on_lookup: :relate)
      argument :version_id, :uuid, allow_nil?: false
      change manage_relationship(:version_id, :version, type: :append, on_lookup: :relate)
      argument :employee_id, :uuid, allow_nil?: false
      change manage_relationship(:employee_id, :employee, type: :append, on_lookup: :relate)
    end
    update :update do
      description "Update Shift Assignment via Update. doc_url: graphql://contract/scheduling/update_scheduling_shift_assignment"
      primary? true
      accept [:starts_at, :ends_at, :source, :is_locked, :notes]
      require_atomic? false
    end
    update :lock do
      description "锁定此排班，重排时不会变动

锁定此排班，重排时不会变动. doc_url: graphql://contract/scheduling/lock_scheduling_shift_assignment"
      accept []
      change set_attribute(:is_locked, true)
      require_atomic? false
    end
    update :unlock do
      description "解锁此排班

解锁此排班. doc_url: graphql://contract/scheduling/unlock_scheduling_shift_assignment"
      accept []
      change set_attribute(:is_locked, false)
      require_atomic? false
    end
  end

  validations do
    validate compare(:ends_at, greater_than: :starts_at)
  end

  identities do
    identity :unique_period_employee_start, [:period_id, :employee_id, :starts_at]
    identity :unique_version_req_employee_start, [:version_id, :requirement_id, :employee_id, :starts_at]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    belongs_to_actor :user, HospitalScheduling.Accounts.User, allow_nil?: true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:constraint_violations]
  end


  pub_sub do
    module HospitalScheduling.PubSub
    prefix "shift_assignment"

    publish :create, ["scheduling.assignment.created"]
    publish :lock, ["scheduling.assignment.locked"]
    publish :unlock, ["scheduling.assignment.unlocked"]
  end
end
