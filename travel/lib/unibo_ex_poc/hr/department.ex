# Workflow: department_write_flow — Department 写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.HR.Department do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "部门"
  end

  postgres do
    table "hr_departments"
    repo UniboExPoc.Repo
  end

  graphql do
    type :hr_department

    queries do
      get :get_hr_department, :read
      list :list_hr_departments, :read
    end

    mutations do
      create :create_hr_department, :create
      update :update_hr_department, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :department_code, :string do
      allow_nil? false
      public? true
      description "部门编号，全局唯一，不可修改"
    end
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :description, :string, public?: true
    attribute :is_active, :boolean do
      default true
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :employees, UniboExPoc.HR.Employee do
      public? true
    end
    belongs_to :parent, UniboExPoc.HR.Department do
      public? true
    end
    belongs_to :manager, UniboExPoc.HR.Employee do
      public? true
    end
    has_many :children, UniboExPoc.HR.Department do
      public? true
      source_attribute :parent_id
      destination_attribute :parent_id
    end
    has_many :job_requisitions, UniboExPoc.HR.JobRequisition do
      public? true
    end
    has_many :employee_skill_logs, UniboExPoc.HR.EmployeeSkillLog do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:department_code, :name, :description]
      argument :parent_id, :uuid
      argument :manager_id, :uuid
      validate present(:department_code)
      validate present(:name)
      # validation: custom_check
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :description, :is_active, :manager_id]
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate immutable :department_code (incompatible with bulk update atomic path)
      change UniboExPoc.HR.Changes.Department.UpdateCall1
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_department_code, [:department_code]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
