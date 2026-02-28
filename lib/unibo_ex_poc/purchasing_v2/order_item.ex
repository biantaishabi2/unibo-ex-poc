defmodule UniboExPoc.PurchasingV2.OrderItem do
  @moduledoc """
  V2 订单行项：保持聚合内子实体模型，验证核心+定制共存。
  """
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.PurchasingV2,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  graphql do
    type(:order_item_v2)

    queries do
      list(:list_order_items_v2, :read)
    end
  end

  postgres do
    table("v2_order_items")
    repo(UniboExPoc.Repo)
  end

  attributes do
    uuid_primary_key(:id)

    attribute :seq_id, :integer do
      allow_nil?(false)
      public?(true)
    end

    attribute :quantity, :decimal do
      allow_nil?(false)
      constraints(min: 0)
      public?(true)
    end

    attribute :unit_price, :decimal do
      allow_nil?(false)
      constraints(min: 0)
      public?(true)
    end

    attribute :subtotal, :decimal do
      public?(true)
    end

    create_timestamp(:inserted_at)
    update_timestamp(:updated_at)
  end

  relationships do
    belongs_to :order, UniboExPoc.PurchasingV2.Order do
      allow_nil?(false)
      public?(true)
    end

    belongs_to :product, UniboExPoc.PurchasingV2.Product do
      public?(true)
    end
  end

  actions do
    defaults([:read, :destroy])

    create :create do
      primary?(true)
      accept([:seq_id, :quantity, :unit_price])
      argument(:product_id, :uuid)

      change(manage_relationship(:product_id, :product, type: :append, on_lookup: :relate))

      # 行项小计自动计算
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
      accept([:quantity, :unit_price])

      # 更新后重算小计
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

  identities do
    identity(:order_item_seq_unique, [:order_id, :seq_id], pre_check?: true)
  end
end
