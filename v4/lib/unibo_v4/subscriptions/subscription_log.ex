# Workflow: log_creation — MRR 变动日志创建（append-only）
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
# ```
defmodule UniboV4.Subscriptions.SubscriptionLog do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Subscriptions,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "subscriptions_subscription_logs"
    repo UniboV4.Repo
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
    end
    attribute :event_date, :date do
      allow_nil? false
      public? true
    end
    attribute :amount_signed, :decimal do
      allow_nil? false
      public? true
    end
    attribute :mrr_before, :decimal do
      allow_nil? false
      public? true
    end
    attribute :mrr_after, :decimal do
      allow_nil? false
      public? true
    end
    attribute :reason, :string, public?: true
    create_timestamp :inserted_at
  end

  relationships do
    belongs_to :subscription, UniboV4.Subscriptions.SubscriptionOrder do
      public? true
      allow_nil? false
    end
    belongs_to :currency, UniboV4.Subscriptions.Currency do
      public? true
      allow_nil? false
    end
    belongs_to :user, UniboV4.Subscriptions.User do
      public? true
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
      # TODO: 跨实体聚合表达式暂不支持
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
  end

  validations do
    # TODO: 不支持的校验规则 custom
  end

end
