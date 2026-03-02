defmodule UniboV4.HR.PaySlip do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "pay_slips"
    repo UniboV4.Repo
  end

  graphql do
    type :pay_slip

    queries do
      get :get_pay_slip, :read
      list :list_pay_slips, :read
    end

    mutations do
      create :create_pay_slip, :create
      update :confirm_pay_slip, :confirm
      update :mark_paid_pay_slip, :mark_paid
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :payslip_number, :string, allow_nil?: false, public?: true
    attribute :period, :string, allow_nil?: false, public?: true
    attribute :basic_salary, :decimal, allow_nil?: false, public?: true
    attribute :allowances, :decimal, default: 0, public?: true
    attribute :deductions, :decimal, default: 0, public?: true
    attribute :net_salary, :decimal, allow_nil?: false, public?: true
    attribute :status, :atom do
      constraints one_of: [:draft, :confirmed, :paid]
      default :draft
        public? true
    end
    attribute :pay_date, :date, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :employee, UniboV4.HR.Employee do
      allow_nil? false
        public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:payslip_number, :period, :basic_salary, :allowances, :deductions, :net_salary, :pay_date]
      argument :employee_id, :uuid, allow_nil?: false
      change manage_relationship(:employee_id, :employee, type: :append, on_lookup: :relate)
      validate present(:payslip_number)
    end
    update :confirm do
      accept []
      validate attribute_equals(:status, :draft) do
        message "只有草稿状态可以确认"
      end
      change set_attribute(:status, :confirmed)
    end
    update :mark_paid do
      accept []
      validate attribute_equals(:status, :confirmed) do
        message "只有已确认状态可以标记发放"
      end
      change set_attribute(:status, :paid)
    end
  end

  identities do
    identity :unique_payslip_number, [:payslip_number]
  end

end
