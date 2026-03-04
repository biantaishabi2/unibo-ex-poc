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
defmodule UniboV4.HR.LeaveRequest do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.HR,
    data_layer: AshPostgres.DataLayer,
    notifiers: [UniboV4.HR.LeaveRequest.Notifier]

  postgres do
    table "hr_leave_requests"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :status, :atom do
      constraints one_of: [:draft, :confirm, :validate1, :validate, :refuse]
      default :draft
      public? true
    end
    attribute :date_from, :utc_datetime do
      allow_nil? false
      public? true
    end
    attribute :date_to, :utc_datetime do
      allow_nil? false
      public? true
    end
    attribute :number_of_days, :decimal, public?: true
    attribute :number_of_hours, :decimal, public?: true
    attribute :reason, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :employee, UniboV4.HR.Employee do
      public? true
      allow_nil? false
    end
    belongs_to :leave_type, UniboV4.HR.LeaveType do
      public? true
      allow_nil? false
    end
    belongs_to :first_approver, UniboV4.HR.Employee do
      public? true
    end
    belongs_to :second_approver, UniboV4.HR.Employee do
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
    update :action_confirm do
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
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:status, :confirm)
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
    update :action_approve do
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
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # TODO: 不支持的 change effect conditional_set_attribute
      # TODO: 不支持的 change effect conditional_set_attribute
      # TODO: 不支持的 change effect custom
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
    update :action_validate do
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
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:status, :validate)
      # TODO: 不支持的 change effect custom
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
    update :action_refuse do
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
    update :action_draft do
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

  validations do
    validate compare(:date_from, less_than_or_equal_to: :date_to)
  end

end
