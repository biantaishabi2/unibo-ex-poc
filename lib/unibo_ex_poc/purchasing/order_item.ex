defmodule UniboExPoc.Purchasing.OrderItem do
  @moduledoc """
  订单行项 — 对应 OFBiz OrderItem。

  属于 Order 聚合根，不能独立于 Order 存在。
  包含数量、单价、金额计算（Determination）。
  """
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Purchasing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  graphql do
    type :order_item

    queries do
      list :list_order_items, :read
    end
  end

  postgres do
    table "order_items"
    repo UniboExPoc.Repo
  end

  attributes do
    uuid_primary_key :id

    # 对应 OFBiz OrderItem.orderItemSeqId — 行项序号
    attribute :seq_id, :integer do
      allow_nil? false
    end

    # 对应 OFBiz OrderItem.itemDescription
    attribute :description, :string

    # 对应 OFBiz OrderItem.quantity
    attribute :quantity, :decimal do
      allow_nil? false
      constraints min: 0
    end

    # 对应 OFBiz OrderItem.cancelQuantity
    attribute :cancel_quantity, :decimal do
      default Decimal.new(0)
    end

    # 对应 OFBiz OrderItem.unitPrice
    attribute :unit_price, :decimal do
      allow_nil? false
      constraints min: 0
    end

    # 对应 OFBiz OrderItem.unitListPrice — 目录价
    attribute :unit_list_price, :decimal

    # Determination: 小计 = 数量 × 单价（写入时计算）
    attribute :subtotal, :decimal

    # 对应 OFBiz OrderItem.statusId
    attribute :status, :atom do
      constraints one_of: [:created, :approved, :completed, :cancelled, :rejected]
      default :created
    end

    # 对应 OFBiz OrderItem.estimatedDeliveryDate
    attribute :estimated_delivery_date, :date

    # 对应 OFBiz OrderItem.comments
    attribute :comments, :string

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    # 所属订单（聚合根）
    belongs_to :order, UniboExPoc.Purchasing.Order do
      allow_nil? false
    end

    # 对应 OFBiz OrderItem.productId
    belongs_to :product, UniboExPoc.Purchasing.Product
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true
      accept [
        :seq_id, :description, :quantity, :unit_price,
        :unit_list_price, :estimated_delivery_date, :comments
      ]
      argument :order_id, :uuid, allow_nil?: false
      argument :product_id, :uuid

      change manage_relationship(:order_id, :order, type: :append, on_lookup: :relate)
      change manage_relationship(:product_id, :product, type: :append, on_lookup: :relate)

      # Determination: 写入时自动计算小计
      change fn changeset, _context ->
        quantity = Ash.Changeset.get_attribute(changeset, :quantity)
        unit_price = Ash.Changeset.get_attribute(changeset, :unit_price)

        if quantity && unit_price do
          Ash.Changeset.force_change_attribute(changeset, :subtotal, Decimal.mult(quantity, unit_price))
        else
          changeset
        end
      end
    end

    update :update do
      primary? true
      require_atomic? false
      accept [:quantity, :unit_price, :description, :estimated_delivery_date, :comments]

      # Determination: 更新时重算小计
      change fn changeset, _context ->
        quantity = Ash.Changeset.get_attribute(changeset, :quantity)
        unit_price = Ash.Changeset.get_attribute(changeset, :unit_price)

        if quantity && unit_price do
          Ash.Changeset.force_change_attribute(changeset, :subtotal, Decimal.mult(quantity, unit_price))
        else
          changeset
        end
      end
    end
  end

  # Validation: 取消数量不能超过订购数量
  validations do
    validate compare(:cancel_quantity, less_than_or_equal_to: :quantity),
      message: "取消数量不能超过订购数量"
  end
end
