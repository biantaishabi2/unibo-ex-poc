# Workflow: dependent_write_flow — Dependent 写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.HR.Dependent do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "员工家属/被抚养人（用于个税专项扣除等）"
  end

  postgres do
    table "hr_dependents"
    repo UniboExPoc.Repo
  end

  graphql do
    type :hr_dependent

    queries do
      get :get_hr_dependent, :read
      list :list_hr_dependents, :read
    end

    mutations do
      create :create_hr_dependent, :create
      update :update_hr_dependent, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "家属姓名"
    end
    attribute :relationship, :atom do
      allow_nil? false
      constraints one_of: [:spouse, :child, :parent, :other]
      public? true
      description "与员工的关系"
    end
    attribute :birth_date, :date do
      public? true
      description "出生日期"
    end
    attribute :gender, :atom do
      constraints one_of: [:male, :female, :other]
      public? true
    end
    attribute :is_disabled, :boolean do
      default false
      public? true
      description "是否残疾"
    end
    attribute :is_student, :boolean do
      default false
      public? true
      description "是否在读学生"
    end
    attribute :identification_id, :string do
      public? true
      description "家属身份证号（IT0021 扩展，影响税务计算）"
    end
    attribute :is_beneficiary, :boolean do
      default false
      public? true
      description "是否为保险/福利受益人"
    end
    attribute :insurance_policy_number, :string do
      public? true
      description "关联保险单号"
    end
    attribute :tax_deduction_type, :atom do
      constraints one_of: [:child_education, :elderly_care, :housing_loan, :housing_rent, :continuing_education, :serious_illness, :infant_care, :none]
      default :none
      public? true
      description "个税专项附加扣除类型（中国 IT0021 扩展）"
    end
    attribute :valid_from, :date do
      public? true
      description "家属关系生效日期（IT0021 时间切片起始）"
    end
    attribute :valid_to, :date do
      public? true
      description "家属关系失效日期（IT0021 时间切片结束）"
    end
    attribute :inserted_at, :utc_datetime_usec do
      allow_nil? false
      writable? false
      default &DateTime.utc_now/0
      public? true
    end
    attribute :updated_at, :utc_datetime_usec do
      allow_nil? false
      writable? false
      default &DateTime.utc_now/0
      update_default &DateTime.utc_now/0
      public? true
    end
  end

  relationships do
    belongs_to :employee, UniboExPoc.HR.Employee do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      description "Create Dependent via Create. doc_url: graphql://contract/hr/create_hr_dependent"
      primary? true
      accept [:name, :relationship, :birth_date, :gender, :is_disabled, :is_student, :identification_id, :is_beneficiary, :insurance_policy_number, :tax_deduction_type, :valid_from, :valid_to]
      argument :employee_id, :uuid, allow_nil?: false
      change manage_relationship(:employee_id, :employee, type: :append, on_lookup: :relate)
      validate present(:name)
      validate present(:relationship)
    end
    update :update do
      description "Update Dependent via Update. doc_url: graphql://contract/hr/update_hr_dependent"
      primary? true
      accept [:name, :relationship, :birth_date, :gender, :is_disabled, :is_student, :identification_id, :is_beneficiary, :insurance_policy_number, :tax_deduction_type, :valid_from, :valid_to]
      require_atomic? false
    end
  end

end
