# Workflow: close_reason_management — 关闭原因管理
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> update
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Subscriptions.CloseReason do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Subscriptions,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "订阅关闭原因，用于流失分析"
  end

  postgres do
    table "subscriptions_close_reasons"
    repo UniboExPoc.Repo
  end

  graphql do
    type :subscriptions_close_reason

    queries do
      get :get_subscriptions_close_reason, :read
      list :list_subscriptions_close_reasons, :read
    end

    mutations do
      create :create_subscriptions_close_reason, :create
      update :update_subscriptions_close_reason, :update
      destroy :delete_subscriptions_close_reason, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "原因描述"
    end
    attribute :sequence, :integer do
      allow_nil? false
      public? true
      description "排序权重"
    end
    attribute :retention_message, :string do
      public? true
      description "挽留话术，客户选择此原因时展示"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    has_many :subscription_orders, UniboExPoc.Subscriptions.SubscriptionOrder do
      public? true
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :sequence, :retention_message]
      validate present(:name)
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
      accept [:name, :sequence, :retention_message]
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
    validate compare(:sequence, greater_than_or_equal_to: 0)
  end

  identities do
    identity :unique_close_reason_name, [:name]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:subscription_orders]
  end

end
