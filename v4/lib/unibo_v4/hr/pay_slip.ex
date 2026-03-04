# Workflow: payslip_payment_flow — 工资条核验与发放流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   compute_sheet --> [*]
#   action_payslip_done --> [*]
#   action_payslip_paid --> [*]
# ```
# Workflow: payslip_refund_flow — 工资条取消与冲红重算流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   action_payslip_cancel --> [*]
#   refund_sheet --> [*]
#   compute_sheet --> [*]
# ```
defmodule UniboV4.HR.PaySlip do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.HR,
    data_layer: AshPostgres.DataLayer,
    notifiers: [UniboV4.HR.PaySlip.Notifier]

  postgres do
    table "hr_pay_slips"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :payslip_number, :string do
      allow_nil? false
      public? true
    end
    attribute :period_start, :date do
      allow_nil? false
      public? true
    end
    attribute :period_end, :date do
      allow_nil? false
      public? true
    end
    attribute :basic_salary, :decimal, public?: true
    attribute :gross_salary, :decimal, public?: true
    attribute :total_deductions, :decimal do
      default 0
      public? true
    end
    attribute :net_salary, :decimal, public?: true
    attribute :status, :atom do
      constraints one_of: [:draft, :verify, :done, :paid, :cancel]
      default :draft
      public? true
    end
    attribute :pay_date, :date, public?: true
    attribute :credit_note, :boolean do
      default false
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :employee, UniboV4.HR.Employee do
      public? true
      allow_nil? false
    end
    belongs_to :contract, UniboV4.HR.EmploymentContract do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:payslip_number, :period_start, :period_end, :basic_salary, :pay_date]
      argument :employee_id, :uuid, allow_nil?: false
      argument :contract_id, :uuid, allow_nil?: false
      change manage_relationship(:employee_id, :employee, type: :append, on_lookup: :relate)
      change manage_relationship(:contract_id, :contract, type: :append, on_lookup: :relate)
      validate present(:payslip_number)
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
    update :compute_sheet do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以计算薪资"
      change set_attribute(:status, :verify)
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
    update :action_payslip_done do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :verify do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :verify}))
        end
      end
      # message: "只有已核验状态可以确认"
      change set_attribute(:status, :done)
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
    update :action_payslip_paid do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :done do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :done}))
        end
      end
      # message: "只有已确认状态可以标记发放"
      change set_attribute(:status, :paid)
      change set_attribute(:pay_date, &Date.utc_today/0)
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
    update :action_payslip_cancel do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:draft, :verify] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:draft, :verify]}))
        end
      end
      # message: "只有草稿或核验状态可以取消"
      change set_attribute(:status, :cancel)
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
    update :refund_sheet do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :cancel do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :cancel}))
        end
      end
      # message: "只有已取消状态可以冲红"
      change set_attribute(:status, :draft)
      change set_attribute(:credit_note, true)
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
    identity :unique_payslip_number, [:payslip_number]
  end

end
