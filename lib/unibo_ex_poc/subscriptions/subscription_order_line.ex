# Workflow: orderline_management — 订阅订单行管理
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> update
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Subscriptions.SubscriptionOrderLine do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Subscriptions,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "订阅订单明细行"
  end

  postgres do
    table "subscriptions_subscription_order_lines"
    repo UniboV4.Repo
  end

  graphql do
    type :subscriptions_subscription_order_line

    queries do
      get :get_subscriptions_subscription_order_line, :read
      list :list_subscriptions_subscription_order_lines, :read
    end

    mutations do
      create :create_subscriptions_subscription_order_line, :create
      update :update_subscriptions_subscription_order_line, :update
      destroy :delete_subscriptions_subscription_order_line, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "行描述"
    end
    attribute :quantity, :decimal do
      allow_nil? false
      public? true
      description "数量"
    end
    attribute :price_unit, :decimal do
      allow_nil? false
      public? true
      description "单价"
    end
    attribute :discount, :decimal do
      allow_nil? false
      default 0
      public? true
      description "折扣百分比（0-100）"
    end
    attribute :recurring, :boolean do
      allow_nil? false
      public? true
      description "是否为周期性项目"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  calculations do
    calculate :price_subtotal, :decimal, expr((quantity * (price_unit * (1 - (discount / 100)))))
  end

  relationships do
    belongs_to :order, UniboV4.Subscriptions.SubscriptionOrder do
      public? true
      allow_nil? false
    end
    belongs_to :product, UniboV4.Subscriptions.Product do
      public? true
      allow_nil? false
    end
    many_to_many :tax_ids, UniboV4.Subscriptions.Tax do
      public? true
      through UniboV4.Subscriptions.SubscriptionOrderLineTaxLink
      source_attribute_on_join_resource :order_line_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :quantity, :price_unit, :discount, :recurring]
      argument :product_id, :uuid, allow_nil?: false
      argument :order_id, :uuid, allow_nil?: false
      change manage_relationship(:order_id, :order, type: :append, on_lookup: :relate)
      change manage_relationship(:product_id, :product, type: :append, on_lookup: :relate)
      # skipped: set_attribute :price_subtotal 是 calculation
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:quantity, :price_unit, :discount]
      # skipped: set_attribute :price_subtotal 是 calculation
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  validations do
    validate compare(:quantity, greater_than: 0)
    validate compare(:price_unit, greater_than_or_equal_to: 0)
    validate compare(:discount, greater_than_or_equal_to: 0)
    validate compare(:discount, less_than_or_equal_to: 100)
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
