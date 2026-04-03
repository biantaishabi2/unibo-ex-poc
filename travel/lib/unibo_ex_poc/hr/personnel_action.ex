# Workflow: personnel_action_write_flow — PersonnelAction 写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   submit --> [*]
#   approve --> [*]
#   execute --> [*]
# ```
defmodule UniboExPoc.HR.PersonnelAction do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshStateMachine],
    notifiers: [Ash.Notifier.PubSub]

  resource do
    description "人事操作（SAP PA40 人事事件），如入职/调动/晋升/离职等事务性操作，一次操作可打包多个 Infotype 变更"
  end

  postgres do
    table "hr_personnel_actions"
    repo UniboExPoc.Repo
    identity_index_names unique_action_code: "idx_hr_personnel_actions_unique_action_code"
  end

  graphql do
    type :hr_personnel_action

    queries do
      get :get_hr_personnel_action, :read
      list :list_hr_personnel_actions, :read
      get :get_list_hr_personnel_action, :list
      list :list_list_hr_personnel_actions, :list
    end

    mutations do
      create :create_hr_personnel_action, :create
      update :update_hr_personnel_action, :update
      update :submit_hr_personnel_action, :submit
      update :approve_hr_personnel_action, :approve
      update :execute_hr_personnel_action, :execute
      update :cancel_hr_personnel_action, :cancel
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :action_code, :string do
      allow_nil? false
      public? true
      description "操作编码（自动生成，全局唯一）"
    end
    attribute :action_type, :atom do
      allow_nil? false
      constraints one_of: [:hire, :rehire, :transfer, :promotion, :demotion, :salary_change, :leave_of_absence, :return_from_leave, :termination, :retirement, :organizational_change, :contract_change]
      public? true
      description "人事操作类型（SAP Action Type / Reason）"
    end
    attribute :action_reason, :string do
      public? true
      description "操作原因说明"
    end
    attribute :effective_date, :date do
      allow_nil? false
      public? true
      description "生效日期"
    end
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:approved, :cancelled, :draft, :executed, :submitted]
      default :draft
      public? true
      description "操作状态"
    end
    attribute :old_department_id, :uuid do
      public? true
      description "变更前部门（调动/晋升时记录）"
    end
    attribute :new_department_id, :uuid do
      public? true
      description "变更后部门"
    end
    attribute :old_position_id, :uuid do
      public? true
      description "变更前岗位"
    end
    attribute :new_position_id, :uuid do
      public? true
      description "变更后岗位"
    end
    attribute :old_salary, :decimal do
      public? true
      description "变更前薪资"
    end
    attribute :new_salary, :decimal do
      public? true
      description "变更后薪资"
    end
    attribute :notes, :string do
      public? true
      description "备注"
    end
    attribute :executed_at, :utc_datetime do
      public? true
      description "实际执行时间"
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
    belongs_to :requester, UniboExPoc.HR.Employee do
      public? true
    end
    belongs_to :approver, UniboExPoc.HR.Employee do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      description "Create Personnel Action via Create. doc_url: graphql://contract/hr/create_hr_personnel_action"
      primary? true
      accept [:action_type, :action_reason, :effective_date, :old_department_id, :new_department_id, :old_position_id, :new_position_id, :old_salary, :new_salary, :notes]
      argument :employee_id, :uuid, allow_nil?: false
      argument :requester_id, :uuid
      change manage_relationship(:employee_id, :employee, type: :append, on_lookup: :relate)
      validate present(:action_type)
      validate present(:effective_date)
    end
    update :update do
      description "Update Personnel Action via Update. doc_url: graphql://contract/hr/update_hr_personnel_action"
      primary? true
      accept [:action_reason, :effective_date, :new_department_id, :new_position_id, :new_salary, :notes]
      require_atomic? false
    end
    update :submit do
      description "提交审批

提交审批. doc_url: graphql://contract/hr/submit_hr_personnel_action"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以提交"
      change set_attribute(:status, :submitted)
      change AshStateMachine.BuiltinChanges.transition_state(:submitted)
      require_atomic? false
    end
    update :approve do
      description "审批通过

审批通过. doc_url: graphql://contract/hr/approve_hr_personnel_action"
      accept []
      argument :approver_id, :uuid
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :submitted do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :submitted}))
        end
      end
      # message: "只有已提交状态可以审批"
      change set_attribute(:status, :approved)
      change AshStateMachine.BuiltinChanges.transition_state(:approved)
      require_atomic? false
    end
    update :execute do
      description "执行人事操作，联动更新 Employee 主数据

执行人事操作，联动更新 Employee 主数据. doc_url: graphql://contract/hr/execute_hr_personnel_action"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :approved do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :approved}))
        end
      end
      # message: "只有已审批状态可以执行"
      change set_attribute(:status, :executed)
      change set_attribute(:executed_at, &DateTime.utc_now/0)
      change UniboExPoc.HR.Changes.PersonnelAction.ExecuteCall6
      change AshStateMachine.BuiltinChanges.transition_state(:executed)
      require_atomic? false
    end
    update :cancel do
      description "取消人事操作

取消人事操作. doc_url: graphql://contract/hr/cancel_hr_personnel_action"
      accept [:notes]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:draft, :submitted] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:draft, :submitted]}))
        end
      end
      # message: "只有草稿或已提交状态可以取消"
      change set_attribute(:status, :cancelled)
      change AshStateMachine.BuiltinChanges.transition_state(:cancelled)
      require_atomic? false
    end
  end

  identities do
    identity :unique_action_code, [:action_code]
  end


  state_machine do
    initial_states [:draft]
    default_initial_state :draft
    extra_states [:approved, :cancelled, :draft, :executed, :submitted]
    state_attribute :status
    transitions do
      transition :submit, from: :draft, to: :submitted
      transition :approve, from: :submitted, to: :approved
      transition :execute, from: :approved, to: :executed
      transition :cancel, from: :draft, to: :cancelled
      transition :cancel, from: :submitted, to: :cancelled
    end
  end

  pub_sub do
    module UniboExPoc.PubSub
    prefix "personnel_action"

    publish :submit, ["hr.personnel_action.submitted"]
    publish :approve, ["hr.personnel_action.approved"]
    publish :execute, ["hr.personnel_action.executed"]
  end
end
