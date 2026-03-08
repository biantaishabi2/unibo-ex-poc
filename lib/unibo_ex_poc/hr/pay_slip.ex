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
    otp_app: :unibo_ex_poc,
    domain: UniboV4.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboV4.HR.PaySlip.Notifier]

  resource do
    description "工资条"
  end

  postgres do
    table "hr_pay_slips"
    repo UniboV4.Repo
  end

  graphql do
    type :hr_pay_slip

    queries do
      get :get_hr_pay_slip, :read
      list :list_hr_pay_slips, :read
    end

    mutations do
      create :create_hr_pay_slip, :create
      update :compute_sheet_hr_pay_slip, :compute_sheet
      update :action_payslip_done_hr_pay_slip, :action_payslip_done
      update :action_payslip_paid_hr_pay_slip, :action_payslip_paid
      update :action_payslip_cancel_hr_pay_slip, :action_payslip_cancel
      update :refund_sheet_hr_pay_slip, :refund_sheet
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :payslip_number, :string do
      allow_nil? false
      public? true
      description "工资条编号，全局唯一"
    end
    attribute :period_start, :date do
      allow_nil? false
      public? true
      description "薪资周期起始"
    end
    attribute :period_end, :date do
      allow_nil? false
      public? true
      description "薪资周期结束"
    end
    attribute :basic_salary, :decimal do
      public? true
      description "基本工资"
    end
    attribute :gross_salary, :decimal do
      public? true
      description "应发工资（计算字段）= SUM(payslip_line WHERE category=GROSS)"
    end
    attribute :total_deductions, :decimal do
      default 0
      public? true
      description "扣款合计（计算字段）= SUM(payslip_line WHERE category=DED)"
    end
    attribute :net_salary, :decimal do
      public? true
      description "实发工资（计算字段）= gross_salary - total_deductions"
    end
    attribute :status, :atom do
      constraints one_of: [:draft, :verify, :done, :paid, :cancel]
      default :draft
      public? true
    end
    attribute :pay_date, :date do
      public? true
      description "发放日期"
    end
    attribute :credit_note, :boolean do
      default false
      public? true
      description "是否为冲红单"
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
      # validation: custom_check
      change set_attribute(:id, expr(id))
    end
    update :compute_sheet do
      description "计算薪资（按 SalaryRule 顺序执行），从 draft 进入 verify"
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
      # message: "只有草稿状态可以计算薪资"
      change set_attribute(:status, :verify)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :action_payslip_done do
      description "确认工资条，生成会计日记账分录"
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
      change UniboV4.HR.Changes.PaySlip.ActionPayslipDoneCall8
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :action_payslip_paid do
      description "标记已发放，记录 pay_date"
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
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :action_payslip_cancel do
      description "取消工资条"
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
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :refund_sheet do
      description "冲红，创建 credit_note=true 的冲红单"
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
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_payslip_number, [:payslip_number]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
