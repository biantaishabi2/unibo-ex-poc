defmodule HospitalScheduling.Scheduling.MedicalStaffProfile do
  use Ash.Resource,
    otp_app: :hospital_scheduling,
    domain: HospitalScheduling.Scheduling,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "排班域专属护士画像，不复制 HR 主数据"
  end

  postgres do
    table "scheduling_medical_staff_profiles"
    repo HospitalScheduling.Repo
    identity_index_names unique_employee_department: "idx_scheduling_medical_staff_profiles_unique_employee_fd7e3b5a"
  end

  graphql do
    type :scheduling_medical_staff_profile

    queries do
      get :get_scheduling_medical_staff_profile, :read
      list :list_scheduling_medical_staff_profiles, :read
    end

    mutations do
      create :create_scheduling_medical_staff_profile, :create
      update :update_scheduling_medical_staff_profile, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :maturity_score, :decimal do
      allow_nil? false
      default 0
      public? true
      description "成熟度评分"
    end
    attribute :can_lead_shift, :boolean do
      allow_nil? false
      default false
      public? true
      description "是否可带班"
    end
    attribute :work_restrictions, {:array, :string} do
      public? true
      description "工作限制，如 pregnant、breastfeeding"
    end
    attribute :overtime_willing, :boolean do
      allow_nil? false
      default false
      public? true
      description "是否愿意加班"
    end
    attribute :notes, :string do
      public? true
      description "备注"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :employee, HospitalScheduling.Scheduling.Employee do
      public? true
      allow_nil? false
    end
    belongs_to :department, HospitalScheduling.Scheduling.Department do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      description "Create Medical Staff Profile via Create. doc_url: graphql://contract/scheduling/create_scheduling_medical_staff_profile"
      primary? true
      accept [:maturity_score, :can_lead_shift, :work_restrictions, :overtime_willing, :notes]
      argument :employee_id, :uuid, allow_nil?: false
      change manage_relationship(:employee_id, :employee, type: :append, on_lookup: :relate)
      argument :department_id, :uuid, allow_nil?: false
      change manage_relationship(:department_id, :department, type: :append, on_lookup: :relate)
    end
    update :update do
      description "Update Medical Staff Profile via Update. doc_url: graphql://contract/scheduling/update_scheduling_medical_staff_profile"
      primary? true
      accept [:maturity_score, :can_lead_shift, :work_restrictions, :overtime_willing, :notes]
      require_atomic? false
    end
  end

  identities do
    identity :unique_employee_department, [:employee_id, :department_id]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
