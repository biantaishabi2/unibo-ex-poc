defmodule HospitalScheduling.Scheduling.ConstraintViolation do
  use Ash.Resource,
    otp_app: :hospital_scheduling,
    domain: HospitalScheduling.Scheduling,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "结构化记录约束违反（error 或 warning）"
  end

  postgres do
    table "scheduling_constraint_violations"
    repo HospitalScheduling.Repo
  end

  graphql do
    type :scheduling_constraint_violation

    queries do
      get :get_scheduling_constraint_violation, :read
      list :list_scheduling_constraint_violations, :read
    end

    mutations do
      create :create_scheduling_constraint_violation, :create
      destroy :delete_scheduling_constraint_violation, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :rule_code, :string do
      allow_nil? false
      public? true
      description "规则编码，如 rest_after_night"
    end
    attribute :severity, :atom do
      allow_nil? false
      constraints one_of: [:error, :warning]
      public? true
      description "严重级别"
    end
    attribute :message, :string do
      allow_nil? false
      public? true
      description "面向用户的说明"
    end
    attribute :details_json, :string do
      allow_nil? false
      public? true
      description "结构化细节"
    end
    create_timestamp :inserted_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :period, HospitalScheduling.Scheduling.SchedulingPeriod do
      public? true
      allow_nil? false
    end
    belongs_to :version, HospitalScheduling.Scheduling.ScheduleVersion do
      public? true
      allow_nil? false
    end
    belongs_to :assignment, HospitalScheduling.Scheduling.ShiftAssignment do
      public? true
    end
    belongs_to :requirement, HospitalScheduling.Scheduling.CoverageRequirement do
      public? true
    end
  end

  actions do
    defaults [:read, :destroy, :update]
    create :create do
      description "Create Constraint Violation via Create. doc_url: graphql://contract/scheduling/create_scheduling_constraint_violation"
      primary? true
      accept [:rule_code, :severity, :message, :details_json]
      argument :period_id, :uuid, allow_nil?: false
      change manage_relationship(:period_id, :period, type: :append, on_lookup: :relate)
      argument :version_id, :uuid, allow_nil?: false
      change manage_relationship(:version_id, :version, type: :append, on_lookup: :relate)
      argument :assignment_id, :uuid, allow_nil?: true
      change manage_relationship(:assignment_id, :assignment, type: :append, on_lookup: :relate)
      argument :requirement_id, :uuid, allow_nil?: true
      change manage_relationship(:requirement_id, :requirement, type: :append, on_lookup: :relate)
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
