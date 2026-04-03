# Workflow: employee_subgroup_write_flow — EmployeeSubgroup 写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.HR.EmployeeSubgroup do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "员工子组（SAP Employee Subgroup），在员工组内进一步细分，影响薪资计算和时间管理规则"
  end

  postgres do
    table "hr_employee_subgroups"
    repo UniboExPoc.Repo
    identity_index_names unique_employee_subgroup_code: "idx_hr_employee_subgroups_unique_employee_subgroup_code"
  end

  graphql do
    type :hr_employee_subgroup

    queries do
      get :get_hr_employee_subgroup, :read
      list :list_hr_employee_subgroups, :read
      get :get_list_hr_employee_subgroup, :list
      list :list_list_hr_employee_subgroups, :list
    end

    mutations do
      create :create_hr_employee_subgroup, :create
      update :update_hr_employee_subgroup, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :code, :string do
      allow_nil? false
      public? true
      description "子组编码，全局唯一"
    end
    attribute :name, :string do
      allow_nil? false
      public? true
      description "子组名称（如\"计时工\"、\"计件工\"、\"管理层\"、\"技术岗\"）"
    end
    attribute :payroll_area, :string do
      public? true
      description "薪资区域标识，用于区分不同薪资计算周期"
    end
    attribute :working_hours_per_week, :decimal do
      public? true
      description "每周标准工时（小时），影响加班计算基准"
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
    belongs_to :employee_group, UniboExPoc.HR.EmployeeGroup do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      description "Create Employee Subgroup via Create. doc_url: graphql://contract/hr/create_hr_employee_subgroup"
      primary? true
      accept [:code, :name, :payroll_area, :working_hours_per_week, :description]
      argument :employee_group_id, :uuid, allow_nil?: false
      change manage_relationship(:employee_group_id, :employee_group, type: :append, on_lookup: :relate)
      validate present(:code)
      validate present(:name)
    end
    update :update do
      description "Update Employee Subgroup via Update. doc_url: graphql://contract/hr/update_hr_employee_subgroup"
      primary? true
      accept [:name, :payroll_area, :working_hours_per_week, :is_active, :description]
      # skipped: validate immutable :code (incompatible with bulk update atomic path)
      require_atomic? false
    end
  end

  identities do
    identity :unique_employee_subgroup_code, [:code]
  end

end
