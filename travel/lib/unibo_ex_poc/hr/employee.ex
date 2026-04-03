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
defmodule UniboExPoc.HR.Employee do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshStateMachine],
    notifiers: [Ash.Notifier.PubSub]

  resource do
    description "员工"
  end

  postgres do
    table "hr_employees"
    repo UniboExPoc.Repo
    identity_index_names unique_employee_code: "idx_hr_employees_unique_employee_code"
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
      description "工号，全局唯一"
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
      description "员工类型"
    end
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:active, :on_leave, :suspended, :terminated]
      default :active
      public? true
    end
    attribute :departure_reason, :string do
      public? true
      description "离职原因"
    end
    attribute :departure_date, :date do
      public? true
      description "离职日期"
    end
    attribute :work_permit_expiry_date, :date do
      public? true
      description "工作许可到期日"
    end
    attribute :address, :string, public?: true
    attribute :notes, :string, public?: true
    attribute :email_sent, :boolean do
      default false
      public? true
      description "是否有发送邮件记录（用于在线状态判定）"
    end
    attribute :ip_connected, :boolean do
      default false
      public? true
      description "是否有 IP 登录记录（用于在线状态判定）"
    end
    attribute :manually_set_present, :boolean do
      default false
      public? true
      description "是否手动设置在线"
    end
    attribute :bank_account_id, :uuid do
      public? true
      description "主银行账户"
    end
    attribute :hr_presence_state, :atom do
      constraints one_of: [:to_define, :present, :absent]
      default :to_define
      public? true
      description "在线状态（综合 email/ip/手动 信号判定）"
    end
    attribute :marital, :atom do
      constraints one_of: [:single, :married, :cohabitant, :widower, :divorced]
      public? true
      description "婚姻状况"
    end
    attribute :certificate, :atom do
      constraints one_of: [:other, :bachelor, :master, :doctor, :graduate]
      public? true
      description "最高学历"
    end
    attribute :study_field, :string do
      public? true
      description "专业"
    end
    attribute :study_school, :string do
      public? true
      description "毕业学校"
    end
    attribute :emergency_contact, :string do
      public? true
      description "紧急联系人"
    end
    attribute :emergency_phone, :string do
      public? true
      description "紧急联系电话"
    end
    attribute :children, :integer do
      default 0
      public? true
      description "子女数"
    end
    attribute :identification_id, :string do
      public? true
      description "身份证号"
    end
    attribute :passport_id, :string do
      public? true
      description "护照号"
    end
    attribute :visa_no, :string do
      public? true
      description "签证号"
    end
    attribute :visa_expire, :date do
      public? true
      description "签证到期日"
    end
    attribute :barcode, :string do
      public? true
      description "考勤 Badge ID"
    end
    attribute :pin, :string do
      public? true
      description "考勤 PIN"
    end
    attribute :leave_manager_id, :uuid do
      public? true
      description "请假审批人"
    end
    attribute :departure_reason_id, :uuid do
      public? true
      description "离职原因（关联 DepartureReason）"
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
    belongs_to :party, UniboExPoc.HR.Party do
      public? true
      allow_nil? false
    end
    belongs_to :department, UniboExPoc.HR.Department do
      public? true
    end
    belongs_to :position, UniboExPoc.HR.JobPosition do
      public? true
    end
    belongs_to :parent, UniboExPoc.HR.Employee do
      public? true
    end
    belongs_to :coach, UniboExPoc.HR.Employee do
      public? true
    end
    belongs_to :employee_group, UniboExPoc.HR.EmployeeGroup do
      public? true
    end
    belongs_to :employee_subgroup, UniboExPoc.HR.EmployeeSubgroup do
      public? true
    end
    has_many :contracts, UniboExPoc.HR.EmploymentContract do
      public? true
    end
    has_many :attendances, UniboExPoc.HR.Attendance do
      public? true
    end
    has_many :employee_locations, UniboExPoc.HR.EmployeeLocation do
      public? true
    end
    has_many :employee_journeys, UniboExPoc.HR.EmployeeJourney do
      public? true
    end
    has_many :personnel_actions, UniboExPoc.HR.PersonnelAction do
      public? true
    end
    has_many :dependents, UniboExPoc.HR.Dependent do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      description "Create Employee via Create. doc_url: graphql://contract/hr/create_hr_employee"
      primary? true
      accept [:employee_code, :first_name, :last_name, :email, :phone, :gender, :birth_date, :hire_date, :employee_type, :address, :notes]
      argument :department_id, :uuid
      argument :position_id, :uuid
      argument :parent_id, :uuid
      argument :coach_id, :uuid
      argument :party_id, :uuid, allow_nil?: false
      change manage_relationship(:party_id, :party, type: :append, on_lookup: :relate)
      validate present(:employee_code)
      validate present(:first_name)
      # validation: custom_check
    end
    update :update do
      description "Update Employee via Update. doc_url: graphql://contract/hr/update_hr_employee"
      primary? true
      accept [:email, :phone, :address, :status, :notes, :employee_type, :work_permit_expiry_date]
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      require_atomic? false
    end
    update :terminate do
      description "离职，清空 parent_id 和 coach_id，记录 departure_date 和 departure_reason

离职，清空 parent_id 和 coach_id，记录 departure_date 和 departure_reason. doc_url: graphql://contract/hr/terminate_hr_employee"
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
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:status, :terminated)
      change set_attribute(:departure_date, &Date.utc_today/0)
      change set_attribute(:parent_id, nil)
      change set_attribute(:coach_id, nil)
      change AshStateMachine.BuiltinChanges.transition_state(:terminated)
      require_atomic? false
    end
    update :suspend do
      description "停职

停职. doc_url: graphql://contract/hr/suspend_hr_employee"
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
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:status, :suspended)
      change AshStateMachine.BuiltinChanges.transition_state(:suspended)
      require_atomic? false
    end
    update :reactivate do
      description "复职，清空 departure_date 和 departure_reason

复职，清空 departure_date 和 departure_reason. doc_url: graphql://contract/hr/reactivate_hr_employee"
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
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:status, :active)
      change set_attribute(:departure_date, nil)
      change set_attribute(:departure_reason, nil)
      change AshStateMachine.BuiltinChanges.transition_state(:active)
      require_atomic? false
    end
  end

  identities do
    identity :unique_employee_code, [:employee_code]
  end


  state_machine do
    initial_states [:active]
    default_initial_state :active
    extra_states [:active, :on_leave, :suspended, :terminated]
    state_attribute :status
    transitions do
      transition :terminate, from: :active, to: :terminated
      transition :suspend, from: :active, to: :suspended
      transition :go_on_leave, from: :active, to: :on_leave
      transition :reactivate, from: :suspended, to: :active
      transition :return_from_leave, from: :on_leave, to: :active
      transition :terminate, from: :on_leave, to: :terminated
    end
  end

  pub_sub do
    module UniboExPoc.PubSub
    prefix "employee"

    publish :terminate, ["hr.employee.terminated"]
    publish :create, ["hr.employee.created"]
  end
end
