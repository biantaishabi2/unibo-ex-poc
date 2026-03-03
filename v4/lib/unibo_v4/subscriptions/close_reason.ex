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
defmodule UniboV4.Subscriptions.CloseReason do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Subscriptions,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "subscriptions_close_reasons"
    repo UniboV4.Repo
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
    end
    attribute :sequence, :integer do
      allow_nil? false
      public? true
    end
    attribute :retention_message, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :subscription_orders, UniboV4.Subscriptions.SubscriptionOrder do
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

end
