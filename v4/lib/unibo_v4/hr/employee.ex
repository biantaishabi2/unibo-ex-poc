defmodule UniboV4.HR.Employee do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.HR.Employee.Notifier]

  postgres do
    table "employees"
    repo UniboV4.Repo
  end

  graphql do
    type :employee

    queries do
      get :get_employee, :read
      list :list_employees, :read
    end

    mutations do
      create :create_employee, :create
      update :update_employee, :update
      update :terminate_employee, :terminate
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :employee_code, :string, allow_nil?: false
    attribute :first_name, :string, allow_nil?: false
    attribute :last_name, :string, allow_nil?: false
    attribute :email, :string
    attribute :phone, :string
    attribute :gender, :atom, constraints: [one_of: [:male, :female, :other]]
    attribute :birth_date, :date
    attribute :hire_date, :date, allow_nil?: false
    attribute :status, :atom do
      constraints one_of: [:active, :on_leave, :terminated]
      default :active
    end
    attribute :address, :string
    attribute :notes, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :department, UniboV4.HR.Department
    belongs_to :position, UniboV4.HR.JobPosition
    has_many :contracts, UniboV4.HR.EmploymentContract
    has_many :leave_requests, UniboV4.HR.LeaveRequest
    has_many :attendances, UniboV4.HR.Attendance
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:employee_code, :first_name, :last_name, :email, :phone, :gender, :birth_date, :hire_date, :address, :notes]
      argument :department_id, :uuid
      argument :position_id, :uuid
      validate present(:employee_code)
      validate present(:first_name)
    end
    update :update do
      primary? true
      accept [:email, :phone, :address, :status, :notes]
    end
    update :terminate do
      accept []
      validate attribute_in(:status, [:active, :on_leave]) do
        message "只有在职或休假状态可以离职"
      end
      change set_attribute(:status, :terminated)
    end
  end

  identities do
    identity :unique_employee_code, [:employee_code]
  end

end
