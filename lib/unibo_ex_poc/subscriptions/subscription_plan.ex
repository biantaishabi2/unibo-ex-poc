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
defmodule UniboExPoc.Subscriptions.SubscriptionPlan do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Subscriptions,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "周期计划模板，定义计费周期和宽限策略"
  end

  postgres do
    table "subscriptions_subscription_plans"
    repo UniboExPoc.Repo
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
      description "计划名称，如\"月度计划\"、\"年度计划\""
    end
    attribute :billing_period_unit, :atom do
      allow_nil? false
      constraints one_of: [:week, :month, :year]
      public? true
      description "计费周期单位"
    end
    attribute :billing_period_value, :integer do
      allow_nil? false
      public? true
      description "周期数值，与 unit 组合确定计费频率"
    end
    attribute :auto_close_limit, :integer do
      allow_nil? false
      default 0
      public? true
      description "支付失败宽限天数，0 表示不自动关闭"
    end
    attribute :active, :boolean do
      allow_nil? false
      default true
      public? true
      description "是否启用"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :subscription_orders, UniboExPoc.Subscriptions.SubscriptionOrder do
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
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :billing_period_unit, :billing_period_value, :auto_close_limit, :active]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :deactivate do
      description "停用计划"
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
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :activate do
      description "启用计划"
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
      change set_attribute(:id, expr(id))
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

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
