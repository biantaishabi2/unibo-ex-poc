# Workflow: employee_group_write_flow — EmployeeGroup 写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.HR.EmployeeGroup do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "员工组（SAP Personnel Structure），细分员工类别以影响薪资规则和考勤规则"
  end

  postgres do
    table "hr_employee_groups"
    repo UniboExPoc.Repo
    identity_index_names unique_employee_group_code: "idx_hr_employee_groups_unique_employee_group_code"
  end

  graphql do
    type :hr_employee_group

    queries do
      get :get_hr_employee_group, :read
      list :list_hr_employee_groups, :read
    end

    mutations do
      create :create_hr_employee_group, :create
      update :update_hr_employee_group, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :code, :string do
      allow_nil? false
      public? true
      description "组编码，全局唯一"
    end
    attribute :name, :string do
      allow_nil? false
      public? true
      description "组名称（如\"在职人员\"、\"退休返聘\"、\"外部顾问\"）"
    end
    attribute :group_type, :atom do
      allow_nil? false
      constraints one_of: [:active, :retiree, :external, :trainee]
      public? true
      description "员工组大类（SAP Employee Group）"
    end
    attribute :subgroup, :string do
      public? true
      description "子组名称（SAP Employee Subgroup，如\"计时工\"、\"计件工\"、\"管理层\"）"
    end
    attribute :payroll_rule_tag, :string do
      public? true
      description "关联薪资规则标签，用于薪资计算时按组匹配规则"
    end
    attribute :time_rule_tag, :string do
      public? true
      description "关联考勤规则标签，用于排班和加班计算"
    end
    attribute :is_active, :boolean do
      default true
      public? true
    end
    attribute :description, :string, public?: true
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
    has_many :subgroups, UniboExPoc.HR.EmployeeSubgroup do
      public? true
      destination_attribute :employee_group_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      description "Create Employee Group via Create. doc_url: graphql://contract/hr/create_hr_employee_group"
      primary? true
      accept [:code, :name, :group_type, :subgroup, :payroll_rule_tag, :time_rule_tag, :description]
      validate present(:code)
      validate present(:name)
    end
    update :update do
      description "Update Employee Group via Update. doc_url: graphql://contract/hr/update_hr_employee_group"
      primary? true
      accept [:name, :subgroup, :payroll_rule_tag, :time_rule_tag, :is_active, :description]
      # skipped: validate immutable :code (incompatible with bulk update atomic path)
      require_atomic? false
    end
  end

  identities do
    identity :unique_employee_group_code, [:code]
  end

end
