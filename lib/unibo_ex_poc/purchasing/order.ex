defmodule UniboExPoc.Purchasing.Order do
  @moduledoc """
  采购订单 — 对应 OFBiz OrderHeader，是采购领域的聚合根。

  OFBiz 中 OrderHeader 通过 orderTypeId 区分 PURCHASE_ORDER / SALES_ORDER，
  这里 POC 阶段只聚焦采购订单。

  聚合边界：Order 管理其下的 OrderItem（通过 manage_relationship）。
  """
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Purchasing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  graphql do
    type :order

    queries do
      get :get_order, :read
      list :list_orders, :read
    end

    mutations do
      create :create_order, :create
      update :update_order, :update
      update :approve_order, :approve
      update :reject_order, :reject
      update :cancel_order, :cancel
      update :complete_order, :complete
      destroy :delete_order, :destroy
    end
  end

  postgres do
    table "orders"
    repo UniboExPoc.Repo
  end

  attributes do
    uuid_primary_key :id

    # 对应 OFBiz OrderHeader.orderName
    attribute :order_name, :string do
      public? true
    end

    # 对应 OFBiz OrderHeader.externalId
    attribute :external_id, :string do
      public? true
    end

    # 对应 OFBiz OrderHeader.orderDate
    attribute :order_date, :utc_datetime do
      default &DateTime.utc_now/0
      public? true
    end

    # 对应 OFBiz OrderHeader.statusId — 采购订单状态机
    attribute :status, :atom do
      constraints one_of: [
        :created,       # ORDER_CREATED
        :approved,      # ORDER_APPROVED
        :held,          # ORDER_HOLD
        :processing,    # ORDER_PROCESSING
        :completed,     # ORDER_COMPLETED
        :rejected,      # ORDER_REJECTED
        :cancelled      # ORDER_CANCELLED
      ]
      default :created
      allow_nil? false
      public? true
    end

    # 对应 OFBiz OrderHeader.currencyUom
    attribute :currency, :string do
      default "CNY"
      public? true
    end

    # 对应 OFBiz OrderHeader.grandTotal — Determination: 自动计算
    attribute :grand_total, :decimal do
      default Decimal.new(0)
      public? true
    end

    # 对应 OFBiz OrderHeader.priority
    attribute :priority, :atom do
      constraints one_of: [:low, :normal, :high, :urgent]
      default :normal
      public? true
    end

    # 对应 OFBiz OrderHeader.needsInventoryIssuance
    attribute :needs_inventory_issuance, :boolean do
      default false
      public? true
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    # 对应 OFBiz OrderRole（roleTypeId=BILL_FROM_VENDOR）→ 供应商
    belongs_to :supplier, UniboExPoc.Purchasing.Party do
      allow_nil? false
      public? true
    end

    # 对应 OFBiz OrderRole（roleTypeId=BILL_TO_CUSTOMER）→ 买方
    belongs_to :buyer, UniboExPoc.Purchasing.Party do
      public? true
    end

    # 聚合根管理的子实体
    has_many :items, UniboExPoc.Purchasing.OrderItem do
      public? true
    end
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [
        :order_name, :external_id, :order_date, :currency,
        :priority, :needs_inventory_issuance
      ]
      argument :supplier_id, :uuid, allow_nil?: false
      argument :buyer_id, :uuid

      # 聚合根管理子实体 — 对应 DDD manage_relationship
      argument :items, {:array, :map}, default: []

      change manage_relationship(:supplier_id, :supplier, type: :append, on_lookup: :relate)
      change manage_relationship(:buyer_id, :buyer, type: :append, on_lookup: :relate)
      change manage_relationship(:items, :items, type: :create)
    end

    update :update do
      accept [:order_name, :priority, :needs_inventory_issuance]

      argument :items, {:array, :map}
      change manage_relationship(:items, :items, on_lookup: :relate, on_no_match: :create, on_match: :update)
    end

    # 状态流转 Action — 对应 OFBiz OrderStatus 的状态机
    update :approve do
      accept []

      # Validation: 只有 created 状态可以审批
      validate attribute_equals(:status, :created) do
        message "只有「已创建」状态的订单可以审批"
      end

      change set_attribute(:status, :approved)
    end

    update :reject do
      accept []
      validate attribute_in(:status, [:created, :approved]) do
        message "只有「已创建」或「已审批」状态的订单可以驳回"
      end
      change set_attribute(:status, :rejected)
    end

    update :cancel do
      accept []
      validate attribute_does_not_equal(:status, :completed) do
        message "已完成的订单不能取消"
      end
      validate attribute_does_not_equal(:status, :cancelled) do
        message "订单已取消"
      end
      change set_attribute(:status, :cancelled)
    end

    update :complete do
      accept []
      validate attribute_equals(:status, :approved) do
        message "只有「已审批」状态的订单可以完成"
      end
      change set_attribute(:status, :completed)
    end
  end

  # Calculation: 读取时派生字段
  calculations do
    # 订单行项数量
    calculate :item_count, :integer, expr(count(items, query: [filter: expr(true)]))
  end

  # Validation: 写入前校验
  validations do
    validate present(:supplier_id), on: :create, message: "必须指定供应商"
  end

  identities do
    identity :external_id, [:external_id], pre_check?: true
  end
end
