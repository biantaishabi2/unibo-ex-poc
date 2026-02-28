defmodule UniboV4.CRM.SalesForecast do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.CRM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "sales_forecasts"
    repo UniboV4.Repo
  end

  graphql do
    type :sales_forecast

    queries do
      get :get_sales_forecast, :read
      list :list_sales_forecasts, :read
    end

    mutations do
      create :create_sales_forecast, :create
      update :update_sales_forecast, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false
    attribute :period, :string, allow_nil?: false
    attribute :amount, :decimal, allow_nil?: false
    attribute :currency, :string, default: "CNY"
    attribute :notes, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :created_by, UniboV4.Accounts.User
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :period, :amount, :currency, :notes]
      validate present(:name)
      change relate_actor(:created_by)
    end
    update :update do
      primary? true
      accept [:name, :amount, :notes]
    end
  end

  validations do
    validate compare(:amount, greater_than: 0)
  end

end
