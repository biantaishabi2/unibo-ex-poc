# Workflow: plan_lifecycle — 计划生命周期（创建→启用/停用切换）
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> deactivate
#   update --> update
#   update --> deactivate
#   deactivate --> activate
#   activate --> update
#   activate --> deactivate
# ```
defmodule UniboV4.Subscriptions.SubscriptionPlan do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Subscriptions,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "subscriptions_subscription_plans"
    repo UniboV4.Repo
  end

  graphql do
    type :subscriptions_subscription_plan

    queries do
      get :get_subscriptions_subscription_plan, :read
      list :list_subscriptions_subscription_plans, :read
    end

    mutations do
      create :create_subscriptions_subscription_plan, :create
      update :update_subscriptions_subscription_plan, :update
      update :deactivate_subscriptions_subscription_plan, :deactivate
      update :activate_subscriptions_subscription_plan, :activate
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :billing_period_unit, :atom do
      allow_nil? false
      constraints one_of: [:week, :month, :year]
      public? true
    end
    attribute :billing_period_value, :integer do
      allow_nil? false
      public? true
    end
    attribute :auto_close_limit, :integer do
      allow_nil? false
      default 0
      public? true
    end
    attribute :active, :boolean do
      allow_nil? false
      default true
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :subscription_orders, UniboV4.Subscriptions.SubscriptionOrder do
      public? true
      destination_attribute :recurring_plan_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :billing_period_unit, :billing_period_value, :auto_close_limit, :active]
      validate present(:name)
      validate present(:billing_period_unit)
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
      accept [:name, :billing_period_unit, :billing_period_value, :auto_close_limit, :active]
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
    update :deactivate do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :active)
        if current == true do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :active, message: "must equal %{value}", vars: %{value: true}))
        end
      end
      # message: "只有启用状态可以停用"
      change set_attribute(:active, false)
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
    update :activate do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :active)
        if current == false do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :active, message: "must equal %{value}", vars: %{value: false}))
        end
      end
      # message: "只有停用状态可以启用"
      change set_attribute(:active, true)
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
    validate compare(:billing_period_value, greater_than: 0)
    validate compare(:auto_close_limit, greater_than_or_equal_to: 0)
  end

  identities do
    identity :unique_plan_name, [:name]
  end

end
