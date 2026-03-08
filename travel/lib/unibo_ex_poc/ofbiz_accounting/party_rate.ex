defmodule UniboExPoc.Ofbiz.Accounting.PartyRate do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_party_rates"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_party_rate

    queries do
      get :get_accounting_party_rate, :read
      list :list_accounting_party_rates, :read
    end

    mutations do
      create :create_accounting_party_rate, :create
      update :update_accounting_party_rate, :update
      destroy :delete_accounting_party_rate, :destroy
    end

  end

  attributes do
    attribute :party_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :default_rate, :boolean, public?: true
    attribute :percentage_used, :float do
      public? true
      description "timeEntries中记录的实际小时数的百分比，用于任务和发票实际值，如果字段为空，将使用100%"
    end
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
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
