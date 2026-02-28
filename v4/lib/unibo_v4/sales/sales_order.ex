defmodule UniboV4.Sales.SalesOrder do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Sales,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, Ash.Policy.Authorizer],
    notifiers: [UniboV4.Sales.SalesOrder.Notifier]

  postgres do
    table "sales_orders"
    repo UniboV4.Repo
  end

  graphql do
    type :sales_order

    queries do
      get :get_sales_order, :read
      list :list_sales_orders, :read
    end

    mutations do
      create :create_sales_order, :create
      update :confirm_sales_order, :confirm
      update :ship_sales_order, :ship
      update :deliver_sales_order, :deliver
      update :cancel_sales_order, :cancel
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :order_number, :string, allow_nil?: false
    attribute :status, :atom do
      constraints one_of: [:draft, :confirmed, :shipped, :partially_shipped, :delivered, :cancelled]
      default :draft
    end
    attribute :total_amount, :decimal, allow_nil?: false
    attribute :currency, :string, default: "CNY"
    attribute :order_date, :date, allow_nil?: false
    attribute :promised_delivery_date, :date
    attribute :payment_terms, :string
    attribute :shipping_address, :string
    attribute :notes, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :item_count, :integer, expr(count(items, query: [filter: expr(true)]))
  end

  relationships do
    has_many :items, UniboV4.Sales.SalesOrderItem
    belongs_to :customer, UniboV4.Sales.Customer do
      allow_nil? false
    end
    belongs_to :created_by, UniboV4.Accounts.User
    has_many :shipments, UniboV4.Sales.SalesOrderShipment
    has_many :returns, UniboV4.Sales.Return
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:order_number, :order_date, :promised_delivery_date, :payment_terms, :shipping_address, :currency, :notes]
      argument :items, {:array, :string}, allow_nil?: false
      argument :customer_id, :uuid, allow_nil?: false
      change manage_relationship(:items, :items, type: :create)
      change manage_relationship(:customer_id, :customer, type: :append, on_lookup: :relate)
      validate present(:order_number)
      change relate_actor(:created_by)
      # TODO: 跨实体聚合表达式暂不支持
    end
    update :confirm do
      accept []
      argument :items, {:array, :map}, default: []
      change manage_relationship(:items, :items, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_equals(:status, :draft) do
        message "只有草稿状态可以确认"
      end
      # TODO: 跨实体聚合表达式暂不支持
      change set_attribute(:status, :confirmed)
    end
    update :ship do
      accept []
      argument :items, {:array, :map}, default: []
      change manage_relationship(:items, :items, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_equals(:status, :confirmed) do
        message "只有已确认状态可以发货"
      end
      # TODO: 跨实体聚合表达式暂不支持
      change set_attribute(:status, :shipped)
    end
    update :deliver do
      accept []
      argument :items, {:array, :map}, default: []
      change manage_relationship(:items, :items, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_in(:status, [:shipped, :partially_shipped]) do
        message "只有已发货状态可以标记送达"
      end
      # TODO: 跨实体聚合表达式暂不支持
      change set_attribute(:status, :delivered)
    end
    update :cancel do
      accept []
      argument :items, {:array, :map}, default: []
      change manage_relationship(:items, :items, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_in(:status, [:draft, :confirmed]) do
        message "只有草稿或已确认状态可以取消"
      end
      # TODO: 跨实体聚合表达式暂不支持
      change set_attribute(:status, :cancelled)
    end
  end

  validations do
    validate compare(:total_amount, greater_than: 0)
  end

  identities do
    identity :unique_order_number, [:order_number]
  end

  aggregates do
    count :total_items, :items
    sum :total_quantity, :items, field: :quantity
  end

  policies do
    policy action_type(:create) do
      authorize_if expr(role in [:sales_rep, :admin])
    end
    policy action_type(:read) do
      authorize_if always()
    end
  end

end
