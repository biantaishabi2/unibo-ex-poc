# Workflow: procurement_flow — 采购全流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> submit
#   submit --> approve
#   submit --> reject
#   approve --> [*] : approved
#   reject --> submit
#   receive --> [*] : received
# ```
defmodule UniboV4.Purchasing.PurchaseOrder do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Purchasing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, Ash.Policy.Authorizer],
    notifiers: [UniboV4.Purchasing.PurchaseOrder.Notifier]

  postgres do
    table "purchase_orders"
    repo UniboV4.Repo
  end

  graphql do
    type :purchase_order

    queries do
      get :get_purchase_order, :read
      list :list_purchase_orders, :read
    end

    mutations do
      create :create_purchase_order, :create
      update :submit_purchase_order, :submit
      update :approve_purchase_order, :approve
      update :reject_purchase_order, :reject
      update :receive_purchase_order, :receive
      update :cancel_purchase_order, :cancel
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :order_number, :string, allow_nil?: false
    attribute :status, :atom do
      constraints one_of: [:draft, :submitted, :approved, :rejected, :received, :partially_received, :cancelled]
      default :draft
    end
    attribute :total_amount, :decimal, allow_nil?: false
    attribute :currency, :string, default: "CNY"
    attribute :order_date, :date, allow_nil?: false
    attribute :expected_delivery_date, :date
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
    has_many :items, UniboV4.Purchasing.PurchaseOrderItem
    belongs_to :supplier, UniboV4.Purchasing.Supplier do
      allow_nil? false
    end
    belongs_to :created_by, UniboV4.Accounts.User
    has_many :receipts, UniboV4.Purchasing.GoodsReceipt
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:order_number, :order_date, :expected_delivery_date, :payment_terms, :shipping_address, :currency, :notes]
      argument :items, {:array, :string}, allow_nil?: false
      argument :supplier_id, :uuid, allow_nil?: false
      change manage_relationship(:items, :items, type: :create)
      change manage_relationship(:supplier_id, :supplier, type: :append, on_lookup: :relate)
      validate present(:order_number)
      change relate_actor(:created_by)
      # TODO: 跨实体聚合表达式暂不支持
    end
    update :submit do
      accept []
      argument :items, {:array, :map}, default: []
      change manage_relationship(:items, :items, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_equals(:status, :draft) do
        message "只有草稿状态可以提交"
      end
      # TODO: 跨实体聚合表达式暂不支持
      change set_attribute(:status, :submitted)
    end
    update :approve do
      accept []
      argument :items, {:array, :map}, default: []
      change manage_relationship(:items, :items, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_equals(:status, :submitted) do
        message "只有已提交状态可以审批"
      end
      # TODO: 跨实体聚合表达式暂不支持
      change set_attribute(:status, :approved)
    end
    update :reject do
      argument :reason, :string, allow_nil?: false
      argument :items, {:array, :map}, default: []
      change manage_relationship(:items, :items, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_equals(:status, :submitted) do
        message "只有已提交状态可以驳回"
      end
      # TODO: 跨实体聚合表达式暂不支持
      change set_attribute(:status, :rejected)
    end
    update :receive do
      accept []
      argument :items, {:array, :map}, default: []
      change manage_relationship(:items, :items, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_in(:status, [:approved, :partially_received]) do
        message "只有已审批或部分收货状态可以标记收货完成"
      end
      # TODO: 跨实体聚合表达式暂不支持
      change set_attribute(:status, :received)
    end
    update :cancel do
      accept []
      argument :items, {:array, :map}, default: []
      change manage_relationship(:items, :items, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_in(:status, [:draft, :submitted]) do
        message "只有草稿或已提交状态可以取消"
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
      authorize_if expr(role in [:buyer, :admin])
    end
    policy action_type(:read) do
      authorize_if always()
    end
    policy action_type(:update) do
      authorize_if expr(role == :admin or id == created_by_id)
    end
  end

end
