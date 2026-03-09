# Workflow: sales_forecast_management — 销售预测管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> update
# ```
defmodule UniboExPoc.CRM.SalesForecast do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.CRM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "销售预测，含概率加权营收计算和 PLS 机器学习集成"
  end

  postgres do
    table "crm_sales_forecasts"
    repo UniboExPoc.Repo
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
      description "预测周期（如 2026-Q1）"
    end
    attribute :amount, :decimal do
      allow_nil? false
      public? true
      description "预测金额（expected_revenue）"
    end
    attribute :prorated_revenue, :decimal do
      public? true
      description "概率加权营收，公式：expected_revenue * probability / 100"
    end
    attribute :probability, :decimal do
      public? true
      description "预测概率，默认与 automated_probability 同步"
    end
    attribute :automated_probability, :decimal do
      public? true
      description "PLS 朴素贝叶斯分类器计算的自动概率"
    end
    attribute :recurring_revenue, :decimal do
      public? true
      description "经常性收入（订阅模型）"
    end
    attribute :recurring_revenue_monthly, :decimal do
      public? true
      description "月度经常性收入"
    end
    attribute :sale_amount_total, :decimal do
      public? true
      description "已确认销售订单的未税总额（由 sale_crm 桥接），仅统计非 draft/sent/cancel 状态的订单"
    end
    attribute :quotation_count, :integer do
      public? true
      description "关联报价单数量"
    end
    attribute :sale_order_count, :integer do
      public? true
      description "已确认订单数量（排除 draft/sent/cancel）"
    end
    attribute :currency, :string do
      default "CNY"
      public? true
    end
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :created_by, UniboExPoc.CRM.Party do
      public? true
      source_attribute :created_by_party_id
    end
    belongs_to :team, UniboExPoc.CRM.SalesTeam do
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
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :amount, :probability, :recurring_revenue, :recurring_revenue_monthly, :notes]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  validations do
    validate compare(:amount, greater_than: 0)
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
