# Workflow: sales_forecast_management — 销售预测管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> update
# ```
defmodule UniboV4.CRM.SalesForecast do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.CRM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "crm_sales_forecasts"
    repo UniboV4.Repo
  end

  graphql do
    type :crm_sales_forecast

    queries do
      get :get_crm_sales_forecast, :read
      list :list_crm_sales_forecasts, :read
    end

    mutations do
      create :create_crm_sales_forecast, :create
      update :update_crm_sales_forecast, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :period, :string do
      allow_nil? false
      public? true
    end
    attribute :amount, :decimal do
      allow_nil? false
      public? true
    end
    attribute :prorated_revenue, :decimal, public?: true
    attribute :probability, :decimal, public?: true
    attribute :automated_probability, :decimal, public?: true
    attribute :recurring_revenue, :decimal, public?: true
    attribute :recurring_revenue_monthly, :decimal, public?: true
    attribute :sale_amount_total, :decimal, public?: true
    attribute :quotation_count, :integer, public?: true
    attribute :sale_order_count, :integer, public?: true
    attribute :currency, :string do
      default "CNY"
      public? true
    end
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :created_by, UniboV4.CRM.User do
      public? true
    end
    belongs_to :team, UniboV4.CRM.SalesTeam do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :period, :amount, :probability, :recurring_revenue, :recurring_revenue_monthly, :currency, :notes]
      argument :team_id, :uuid
      validate present(:name)
      change relate_actor(:created_by)
      # TODO: 不支持的 change effect compute
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :update do
      primary? true
      accept [:name, :amount, :probability, :recurring_revenue, :recurring_revenue_monthly, :notes]
      # TODO: 不支持的 change effect compute
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
    validate compare(:amount, greater_than: 0)
  end

end
