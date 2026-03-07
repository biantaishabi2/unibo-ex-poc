defmodule UniboExPoc.Ofbiz.Accounting.RateAmount do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_rate_amounts"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_rate_amount

    queries do
      get :get_accounting_rate_amount, :read
      list :list_accounting_rate_amounts, :read
    end

    mutations do
      create :create_accounting_rate_amount, :create
      update :update_accounting_rate_amount, :update
      destroy :delete_accounting_rate_amount, :destroy
    end

  end

  attributes do
    attribute :rate_currency_uom_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :period_type_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :work_effort_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :party_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :empl_position_type_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
      description "描述费率金额何时有效。如果为空，立即有效。"
    end
    attribute :thru_date, :utc_datetime do
      public? true
      description "描述费率金额何时有效。如果为空，无限期有效。"
    end
    attribute :rate_amount, :decimal, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :rate_type, UniboExPoc.Ofbiz.Accounting.RateType do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
