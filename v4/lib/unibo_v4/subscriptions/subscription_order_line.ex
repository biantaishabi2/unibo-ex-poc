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
    data_layer: AshPostgres.DataLayer

  postgres do
    table "subscriptions_subscription_order_lines"
    repo UniboV4.Repo
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
      # skipped: set_attribute :price_subtotal 是 calculation
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
