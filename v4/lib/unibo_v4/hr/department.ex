# Workflow: department_write_flow — Department 写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.HR.Department do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "hr_departments"
    repo UniboV4.Repo
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
    has_many :employees, UniboV4.HR.Employee do
      public? true
    end
    belongs_to :parent, UniboV4.HR.Department do
      public? true
    end
    belongs_to :manager, UniboV4.HR.Employee do
      public? true
    end
    has_many :children, UniboV4.HR.Department do
      public? true
      destination_attribute :parent_id
    end
    has_many :job_requisitions, UniboV4.HR.JobRequisition do
      public? true
    end
    has_many :employee_skill_logs, UniboV4.HR.EmployeeSkillLog do
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
      # TODO: 不支持的 action 内校验规则 custom
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :update do
      primary? true
      accept [:name, :description, :is_active]
      argument :manager_id, :uuid
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate immutable :department_code (incompatible with bulk update atomic path)
      # TODO: 不支持的 change effect custom
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
  end

  identities do
    identity :unique_department_code, [:department_code]
  end

end
