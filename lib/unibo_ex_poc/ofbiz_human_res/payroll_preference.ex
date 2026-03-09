defmodule UniboExPoc.Ofbiz.HumanRes.PayrollPreference do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.HumanRes,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "human_res_payroll_preferences"
    repo UniboExPoc.Repo
  end

  graphql do
    type :human_res_payroll_preference

    queries do
      get :get_human_res_payroll_preference, :read
      list :list_human_res_payroll_preferences, :read
    end

    mutations do
      create :create_human_res_payroll_preference, :create
      update :update_human_res_payroll_preference, :update
      destroy :delete_human_res_payroll_preference, :destroy
    end

  end

  attributes do
    attribute :role_type_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :payroll_preference_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :from_date, :utc_datetime, public?: true
    attribute :thru_date, :utc_datetime, public?: true
    attribute :percentage, :float, public?: true
    attribute :flat_amount, :decimal, public?: true
    attribute :routing_number, :string do
      public? true
      description "银行代码，参见 https://en.wikipedia.org/wiki/Bank_code"
    end
    attribute :account_number, :string, public?: true
    attribute :bank_name, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :party, UniboExPoc.Ofbiz.HumanRes.Party do
      public? true
      attribute_type :string
    end
    belongs_to :deduction_type, UniboExPoc.Ofbiz.HumanRes.DeductionType do
      public? true
      attribute_type :string
    end
    belongs_to :payment_method_type, UniboExPoc.Ofbiz.HumanRes.PaymentMethodType do
      public? true
      attribute_type :string
    end
    belongs_to :period_type, UniboExPoc.Ofbiz.HumanRes.PeriodType do
      public? true
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
