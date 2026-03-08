# Workflow: log_creation — MRR 变动日志创建（append-only）
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
# ```
defmodule UniboExPoc.Subscriptions.SubscriptionLog do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Subscriptions,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "MRR 变动日志，所有 KPI 报表的唯一数据源"
  end

  postgres do
    table "subscriptions_subscription_logs"
    repo UniboExPoc.Repo
  end

  graphql do
    type :subscriptions_subscription_log

    queries do
      get :get_subscriptions_subscription_log, :read
      list :list_subscriptions_subscription_logs, :read
    end

    mutations do
      create :create_subscriptions_subscription_log, :create
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :event_type, :atom do
      allow_nil? false
      constraints one_of: [:creation, :expansion, :contraction, :churn, :reactivation]
      public? true
      description "事件类型"
    end
    attribute :event_date, :date do
      allow_nil? false
      public? true
      description "事件日期"
    end
    attribute :amount_signed, :decimal do
      allow_nil? false
      public? true
      description "MRR 变动金额（正=增长，负=流失）"
    end
    attribute :mrr_before, :decimal do
      allow_nil? false
      public? true
      description "变动前 MRR"
    end
    attribute :mrr_after, :decimal do
      allow_nil? false
      public? true
      description "变动后 MRR"
    end
    attribute :reason, :string do
      public? true
      description "变动原因备注"
    end
    create_timestamp :inserted_at
  end

  relationships do
    belongs_to :subscription, UniboExPoc.Subscriptions.SubscriptionOrder do
      public? true
      allow_nil? false
    end
    belongs_to :currency, UniboExPoc.Subscriptions.Currency do
      public? true
      allow_nil? false
    end
    belongs_to :user, UniboExPoc.Subscriptions.Party do
      public? true
      source_attribute :user_party_id
    end
  end

  actions do
    defaults [:read, :update]
    create :create do
      primary? true
      accept [:event_type, :event_date, :amount_signed, :mrr_before, :mrr_after, :reason]
      argument :subscription_id, :uuid, allow_nil?: false
      argument :currency_id, :uuid, allow_nil?: false
      argument :user_id, :uuid
      change manage_relationship(:subscription_id, :subscription, type: :append, on_lookup: :relate)
      change manage_relationship(:currency_id, :currency, type: :append, on_lookup: :relate)
      validate present(:event_type)
      validate present(:event_date)
      change UniboExPoc.Subscriptions.Changes.SubscriptionLog.ComputeEventDate
      change set_attribute(:id, expr(id))
    end
  end

  validations do
    # validation: amount_signed_consistency — amount_signed 必须等于 mrr_after - mrr_before
  end

end
