# Workflow: employee_write_flow — Employee 写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   terminate --> [*]
#   suspend --> [*]
#   reactivate --> [*]
# ```
defmodule UniboV4.HR.Employee do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.HR.Employee.Notifier]

  postgres do
    table "hr_employees"
    repo UniboV4.Repo
  end

  graphql do
    type :hr_employee

    queries do
      get :get_hr_employee, :read
      list :list_hr_employees, :read
    end

    mutations do
      create :create_hr_employee, :create
      update :update_hr_employee, :update
      update :terminate_hr_employee, :terminate
      update :suspend_hr_employee, :suspend
      update :reactivate_hr_employee, :reactivate
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :employee_code, :string do
      allow_nil? false
      public? true
    end
    attribute :first_name, :string do
      allow_nil? false
      public? true
    end
    attribute :last_name, :string do
      allow_nil? false
      public? true
    end
    attribute :email, :string, public?: true
    attribute :phone, :string, public?: true
    attribute :gender, :atom do
      constraints one_of: [:male, :female, :other]
      public? true
    end
    attribute :birth_date, :date, public?: true
    attribute :hire_date, :date do
      allow_nil? false
      public? true
    end
    attribute :employee_type, :atom do
      constraints one_of: [:employee, :contractor, :freelancer, :intern]
      default :employee
      public? true
    end
    attribute :status, :atom do
      constraints one_of: [:active, :on_leave, :suspended, :terminated]
      default :active
      public? true
    end
    attribute :departure_reason, :string, public?: true
    attribute :departure_date, :date, public?: true
    attribute :work_permit_expiry_date, :date, public?: true
    attribute :address, :string, public?: true
    attribute :notes, :string, public?: true
    attribute :email_sent, :boolean do
      default false
      public? true
    end
    attribute :ip_connected, :boolean do
      default false
      public? true
    end
    attribute :manually_set_present, :boolean do
      default false
      public? true
    end
    attribute :hr_presence_state, :atom do
      constraints one_of: [:to_define, :present, :absent]
      default :to_define
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :department, UniboV4.HR.Department do
      public? true
    end
    belongs_to :position, UniboV4.HR.JobPosition do
      public? true
    end
    belongs_to :parent, UniboV4.HR.Employee do
      public? true
    end
    belongs_to :coach, UniboV4.HR.Employee do
      public? true
    end
    has_many :contracts, UniboV4.HR.EmploymentContract do
      public? true
    end
    has_many :leave_requests, UniboV4.HR.LeaveRequest do
      public? true
    end
    has_many :attendances, UniboV4.HR.Attendance do
      public? true
    end
    has_many :pay_slips, UniboV4.HR.PaySlip do
      public? true
    end
    has_many :performance_reviews, UniboV4.HR.PerformanceReview do
      public? true
    end
    has_many :trainings, UniboV4.HR.Training do
      public? true
    end
    has_many :skills, UniboV4.HR.EmployeeSkill do
      public? true
    end
    has_many :employee_skill_logs, UniboV4.HR.EmployeeSkillLog do
      public? true
    end
    has_many :resume_lines, UniboV4.HR.ResumeLine do
      public? true
    end
    has_many :work_entries, UniboV4.HR.WorkEntry do
      public? true
    end
    has_many :employee_locations, UniboV4.HR.EmployeeLocation do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:employee_code, :first_name, :last_name, :email, :phone, :gender, :birth_date, :hire_date, :employee_type, :address, :notes]
      argument :department_id, :uuid
      argument :position_id, :uuid
      argument :parent_id, :uuid
      argument :coach_id, :uuid
      validate present(:employee_code)
      validate present(:first_name)
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
      accept [:email, :phone, :address, :status, :notes, :employee_type, :work_permit_expiry_date]
      # skipped: validate custom : (incompatible with bulk update atomic path)
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
    update :terminate do
      accept [:departure_reason]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:active, :on_leave] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:active, :on_leave]}))
        end
      end
      # message: "只有在职或休假状态可以离职"
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:status, :terminated)
      change set_attribute(:departure_date, &Date.utc_today/0)
      # TODO: 不支持的 change effect clear_attribute
      # TODO: 不支持的 change effect clear_attribute
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
    update :suspend do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :active do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :active}))
        end
      end
      # message: "只有在职状态可以停职"
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:status, :suspended)
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
    update :reactivate do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :suspended do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :suspended}))
        end
      end
      # message: "只有停职状态可以复职"
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:status, :active)
      # TODO: 不支持的 change effect clear_attribute
      # TODO: 不支持的 change effect clear_attribute
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
    identity :unique_employee_code, [:employee_code]
  end

end
