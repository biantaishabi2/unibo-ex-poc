defmodule HospitalScheduling.Scheduling.SchedulingConstraint do
  use Ash.Resource,
    otp_app: :hospital_scheduling,
    domain: HospitalScheduling.Scheduling,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "合法性约束和评分规则定义，不承载需求人数"
  end

  postgres do
    table "scheduling_constraints"
    repo HospitalScheduling.Repo
  end

  graphql do
    type :scheduling_scheduling_constraint

    queries do
      get :get_scheduling_scheduling_constraint, :read
      list :list_scheduling_scheduling_constraints, :read
    end

    mutations do
      create :create_scheduling_scheduling_constraint, :create
      update :update_scheduling_scheduling_constraint, :update
      destroy :delete_scheduling_scheduling_constraint, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "规则名称"
    end
    attribute :constraint_type, :atom do
      allow_nil? false
      constraints one_of: [:hard, :soft]
      public? true
      description "硬约束或软约束"
    end
    attribute :category, :atom do
      allow_nil? false
      constraints one_of: [:rest_after_night, :max_consecutive_days, :respect_leave, :skill_requirement, :max_monthly_hours, :lead_coverage, :fair_night_distribution, :fair_weekend_distribution, :respect_preference, :limit_consecutive_nights, :shift_continuity]
      public? true
      description "规则类别"
    end
    attribute :params, :map do
      allow_nil? false
      public? true
      description "规则参数（shape 按 category 不同）"
    end
    attribute :weight, :integer do
      default 50
      public? true
      description "软约束权重（硬约束忽略）"
    end
    attribute :enabled, :boolean do
      allow_nil? false
      default true
      public? true
      description "是否启用"
    end
    attribute :notes, :string do
      public? true
      description "备注"
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
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      description "Create Scheduling Constraint via Create. doc_url: graphql://contract/scheduling/create_scheduling_scheduling_constraint"
      primary? true
      accept [:name, :constraint_type, :category, :params, :weight, :enabled, :notes]
      argument :department_id, :uuid, allow_nil?: false
      change manage_relationship(:department_id, :department, type: :append, on_lookup: :relate)
      validate present(:name)
      validate present(:category)
    end
    update :update do
      description "Update Scheduling Constraint via Update. doc_url: graphql://contract/scheduling/update_scheduling_scheduling_constraint"
      primary? true
      accept [:name, :params, :weight, :enabled, :notes]
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
