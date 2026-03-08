# Workflow: leave_request_write_flow — LeaveRequest 写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   action_confirm --> [*]
#   action_approve --> [*]
#   action_validate --> [*]
#   action_refuse --> [*]
#   action_draft --> [*]
# ```
defmodule UniboExPoc.HR.LeaveRequest do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.HR.LeaveRequest.Notifier]

  resource do
    description "请假申请"
  end

  postgres do
    table "hr_leave_requests"
    repo UniboExPoc.Repo
  end

  graphql do
    type :hr_leave_request

    queries do
      get :get_hr_leave_request, :read
      list :list_hr_leave_requests, :read
    end

    mutations do
      create :create_hr_leave_request, :create
      update :action_confirm_hr_leave_request, :action_confirm
      update :action_approve_hr_leave_request, :action_approve
      update :action_validate_hr_leave_request, :action_validate
      update :action_refuse_hr_leave_request, :action_refuse
      update :action_draft_hr_leave_request, :action_draft
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :status, :atom do
      constraints one_of: [:draft, :confirm, :validate1, :validate, :refuse]
      default :draft
      public? true
      description "状态: draft=草稿, confirm=已确认, validate1=一级审批通过, validate=最终审批通过, refuse=已拒绝"
    end
    attribute :date_from, :utc_datetime do
      allow_nil? false
      public? true
      description "请假开始时间"
    end
    attribute :date_to, :utc_datetime do
      allow_nil? false
      public? true
      description "请假结束时间"
    end
    attribute :number_of_days, :decimal do
      public? true
      description "请假天数（计算字段，基于 employee.resource_calendar 计算工作日天数）"
    end
    attribute :number_of_hours, :decimal do
      public? true
      description "请假小时数（计算字段，基于工作日历计算总工时）"
    end
    attribute :reason, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :employee, UniboExPoc.HR.Employee do
      public? true
      allow_nil? false
    end
    belongs_to :leave_type, UniboExPoc.HR.LeaveType do
      public? true
      allow_nil? false
    end
    belongs_to :first_approver, UniboExPoc.HR.Employee do
      public? true
    end
    belongs_to :second_approver, UniboExPoc.HR.Employee do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:date_from, :date_to, :reason]
      argument :employee_id, :uuid, allow_nil?: false
      argument :leave_type_id, :uuid, allow_nil?: false
      change manage_relationship(:employee_id, :employee, type: :append, on_lookup: :relate)
      change manage_relationship(:leave_type_id, :leave_type, type: :append, on_lookup: :relate)
      # validation: custom_check
      change set_attribute(:id, expr(id))
    end
    update :action_confirm do
      description "确认提交请假申请"
      primary? true
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以确认提交"
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:status, :confirm)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :action_approve do
      description "一级审批通过（manager 或 no_validation 类型直接到 validate）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :confirm do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :confirm}))
        end
      end
      # message: "只有已确认状态可以审批"
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:status, :validate1)
      change set_attribute(:status, :validate)
      change UniboExPoc.HR.Changes.LeaveRequest.ActionApproveCall7
      change UniboExPoc.HR.Changes.LeaveRequest.ActionApproveCall8
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :action_validate do
      description "二级审批通过（仅 both 类型需要，从 validate1 到 validate）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :validate1 do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :validate1}))
        end
      end
      # message: "只有一级审批通过状态可以二级审批"
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:status, :validate)
      change UniboExPoc.HR.Changes.LeaveRequest.ActionValidateCall7
      change UniboExPoc.HR.Changes.LeaveRequest.ActionValidateCall8
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :action_refuse do
      description "拒绝请假"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:draft, :confirm, :validate1, :validate] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:draft, :confirm, :validate1, :validate]}))
        end
      end
      # message: "已拒绝的不能再拒绝"
      change set_attribute(:status, :refuse)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :action_draft do
      description "重置为草稿（从 confirm 或 refuse 状态）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:confirm, :refuse] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:confirm, :refuse]}))
        end
      end
      # message: "只有已确认或已拒绝状态可以重置为草稿"
      change set_attribute(:status, :draft)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  validations do
    validate compare(:date_from, less_than_or_equal_to: :date_to)
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
