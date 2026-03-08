defmodule UniboExPoc.Ofbiz.Accounting.ProductAverageCost do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  resource do
    description "特定公司和设施中产品平均成本的运行小计"
  end

  postgres do
    table "accounting_product_average_costs"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_product_average_cost

    queries do
      get :get_accounting_product_average_cost, :read
      list :list_accounting_product_average_costs, :read
    end

    mutations do
      create :create_accounting_product_average_cost, :create
      update :update_accounting_product_average_cost, :update
      destroy :delete_accounting_product_average_cost, :destroy
    end

  end

  attributes do
    attribute :organization_party_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :product_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :facility_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :average_cost, :decimal, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product_average_cost_type, UniboExPoc.Ofbiz.Accounting.ProductAverageCostType do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
