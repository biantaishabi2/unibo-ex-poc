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
    otp_app: :unibo_v4,
    domain: UniboV4.Subscriptions,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

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
    end
    attribute :quantity, :decimal do
      allow_nil? false
      public? true
    end
    attribute :price_unit, :decimal do
      allow_nil? false
      public? true
    end
    attribute :discount, :decimal do
      allow_nil? false
      default 0
      public? true
    end
    attribute :recurring, :boolean do
      allow_nil? false
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :price_subtotal
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
      change fn changeset, _context ->
        quantity = Ash.Changeset.get_attribute(changeset, :quantity)
        price_unit = Ash.Changeset.get_attribute(changeset, :price_unit)
        discount = Ash.Changeset.get_attribute(changeset, :discount)

        if quantity && price_unit && discount do
          Ash.Changeset.force_change_attribute(changeset, :price_subtotal, Decimal.mult(quantity, Decimal.mult(price_unit, Decimal.sub(1, Decimal.div(discount, 100)))))
        else
          changeset
        end
      end
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
      accept [:quantity, :price_unit, :discount]
      change fn changeset, _context ->
        quantity = Ash.Changeset.get_attribute(changeset, :quantity)
        price_unit = Ash.Changeset.get_attribute(changeset, :price_unit)
        discount = Ash.Changeset.get_attribute(changeset, :discount)

        if quantity && price_unit && discount do
          Ash.Changeset.force_change_attribute(changeset, :price_subtotal, Decimal.mult(quantity, Decimal.mult(price_unit, Decimal.sub(1, Decimal.div(discount, 100)))))
        else
          changeset
        end
      end
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
    validate compare(:quantity, greater_than: 0)
    validate compare(:price_unit, greater_than_or_equal_to: 0)
    validate compare(:discount, greater_than_or_equal_to: 0)
    validate compare(:discount, less_than_or_equal_to: 100)
  end

end
