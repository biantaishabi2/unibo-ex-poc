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
    type(:order_item)

    queries do
      list(:list_order_items, :read)
    end
  end

  postgres do
    table("order_items")
    repo(UniboExPoc.Repo)
  end

  attributes do
    uuid_primary_key(:id)

    # 对应 OFBiz OrderItem.orderItemSeqId — 行项序号
    attribute :seq_id, :integer do
      allow_nil?(false)
      public?(true)
    end

    # 对应 OFBiz OrderItem.itemDescription
    attribute :description, :string do
      public?(true)
    end

    # 对应 OFBiz OrderItem.quantity
    attribute :quantity, :decimal do
      allow_nil?(false)
      constraints(min: 0)
      public?(true)
    end

    # 对应 OFBiz OrderItem.cancelQuantity
    attribute :cancel_quantity, :decimal do
      default(Decimal.new(0))
      public?(true)
    end

    # 对应 OFBiz OrderItem.unitPrice
    attribute :unit_price, :decimal do
      allow_nil?(false)
      constraints(min: 0)
      public?(true)
    end

    # 对应 OFBiz OrderItem.unitListPrice — 目录价
    attribute :unit_list_price, :decimal do
      public?(true)
    end

    # Determination: 小计 = 数量 × 单价（写入时计算）
    attribute :subtotal, :decimal do
      public?(true)
    end

    # 对应 OFBiz OrderItem.statusId
    attribute :status, :atom do
      constraints(one_of: [:created, :approved, :completed, :cancelled, :rejected])
      default(:created)
      public?(true)
    end

    # 对应 OFBiz OrderItem.estimatedDeliveryDate
    attribute :estimated_delivery_date, :date do
      public?(true)
    end

    # 对应 OFBiz OrderItem.comments
    attribute :comments, :string do
      public?(true)
    end

    create_timestamp(:inserted_at)
    update_timestamp(:updated_at)
  end

  relationships do
    # 所属订单（聚合根）
    belongs_to :order, UniboExPoc.Purchasing.Order do
      allow_nil?(false)
      public?(true)
    end

    # 对应 OFBiz OrderItem.productId
    belongs_to :product, UniboExPoc.Purchasing.Product do
      public?(true)
    end
  end

  actions do
    defaults([:read, :destroy])

    create :create do
      primary?(true)

      accept([
        :seq_id,
        :description,
        :quantity,
        :unit_price,
        :unit_list_price,
        :estimated_delivery_date,
        :comments
      ])

      argument(:product_id, :uuid)

      change(manage_relationship(:product_id, :product, type: :append, on_lookup: :relate))

      # Determination: 写入时自动计算小计
      change(fn changeset, _context ->
        quantity = Ash.Changeset.get_attribute(changeset, :quantity)
        unit_price = Ash.Changeset.get_attribute(changeset, :unit_price)

        if quantity && unit_price do
          Ash.Changeset.force_change_attribute(
            changeset,
            :subtotal,
            Decimal.mult(quantity, unit_price)
          )
        else
          changeset
        end
      end)
    end

    update :update do
      primary?(true)
      require_atomic?(false)
      accept([:quantity, :unit_price, :description, :estimated_delivery_date, :comments])

      # Determination: 更新时重算小计
      change(fn changeset, _context ->
        quantity = Ash.Changeset.get_attribute(changeset, :quantity)
        unit_price = Ash.Changeset.get_attribute(changeset, :unit_price)

        if quantity && unit_price do
          Ash.Changeset.force_change_attribute(
            changeset,
            :subtotal,
            Decimal.mult(quantity, unit_price)
          )
        else
          changeset
        end
      end)
    end
  end

  # Validation: 取消数量不能超过订购数量
  validations do
    validate(compare(:quantity, greater_than: 0),
      message: "订购数量必须大于 0"
    )

    validate(compare(:unit_price, greater_than: 0),
      message: "单价必须大于 0"
    )

    validate(compare(:cancel_quantity, greater_than_or_equal_to: 0),
      message: "取消数量不能为负数"
    )

    validate(compare(:cancel_quantity, less_than_or_equal_to: :quantity),
      message: "取消数量不能超过订购数量"
    )
  end

  identities do
    # 同一订单内，行项序号必须唯一
    identity(:order_item_seq_unique, [:order_id, :seq_id], pre_check?: true)
  end
end
