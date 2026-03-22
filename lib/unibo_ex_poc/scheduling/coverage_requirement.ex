defmodule UniboExPoc.Scheduling.CoverageRequirement do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Scheduling,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "定义某天某班次某岗位需要多少人"
  end

  postgres do
    table "scheduling_coverage_requirements"
    repo UniboExPoc.Repo
    identity_index_names unique_period_date_shift_role: "idx_scheduling_coverage_requirements_unique_period_dat_461f704c"
  end

  graphql do
    type :scheduling_coverage_requirement

    queries do
      get :get_scheduling_coverage_requirement, :read
      list :list_scheduling_coverage_requirements, :read
    end

    mutations do
      create :create_scheduling_coverage_requirement, :create
      update :update_scheduling_coverage_requirement, :update
      destroy :delete_scheduling_coverage_requirement, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :requirement_date, :date do
      allow_nil? false
      public? true
      description "需求日期（本地业务日）"
    end
    attribute :role_code, :string do
      allow_nil? false
      public? true
      description "岗位编码，如 duty_nurse"
    end
    attribute :role_name, :string do
      public? true
      description "岗位名称"
    end
    attribute :required_skill_tags, :map do
      public? true
      description "所需技能标签，如 [\"ICU\"]"
    end
    attribute :min_headcount, :integer do
      allow_nil? false
      public? true
      description "最低人数"
    end
    attribute :target_headcount, :integer do
      public? true
      description "目标人数，不填时等于 min_headcount"
    end
    attribute :required_lead_count, :integer do
      allow_nil? false
      default 0
      public? true
      description "需要带班人数"
    end
    attribute :priority, :integer do
      allow_nil? false
      default 100
      public? true
      description "优先级，越小越高"
    end
    attribute :notes, :string do
      public? true
      description "备注"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :period, UniboExPoc.Scheduling.SchedulingPeriod do
      public? true
      allow_nil? false
    end
    belongs_to :shift_type, UniboExPoc.Scheduling.ShiftType do
      public? true
      allow_nil? false
    end
    has_many :shift_assignments, UniboExPoc.Scheduling.ShiftAssignment do
      public? true
      destination_attribute :requirement_id
    end
    has_many :constraint_violations, UniboExPoc.Scheduling.ConstraintViolation do
      public? true
      destination_attribute :requirement_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      description "Create Coverage Requirement via Create. doc_url: graphql://contract/scheduling/create_scheduling_coverage_requirement"
      primary? true
      accept [:requirement_date, :role_code, :role_name, :required_skill_tags, :min_headcount, :target_headcount, :required_lead_count, :priority, :notes]
      argument :period_id, :uuid, allow_nil?: false
      change manage_relationship(:period_id, :period, type: :append, on_lookup: :relate)
      argument :shift_type_id, :uuid, allow_nil?: false
      change manage_relationship(:shift_type_id, :shift_type, type: :append, on_lookup: :relate)
      validate present(:requirement_date)
      validate present(:role_code)
    end
    update :update do
      description "Update Coverage Requirement via Update. doc_url: graphql://contract/scheduling/update_scheduling_coverage_requirement"
      primary? true
      accept [:role_name, :required_skill_tags, :min_headcount, :target_headcount, :required_lead_count, :priority, :notes]
      require_atomic? false
    end
  end

  identities do
    identity :unique_period_date_shift_role, [:period_id, :requirement_date, :shift_type_id, :role_code]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
