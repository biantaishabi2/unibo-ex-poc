# Workflow: orderline_management — 订单行管理（创建→修改）
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> update
# ```
defmodule UniboV4.POS.PosOrderLine do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.POS,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "pos_order_lines"
    repo UniboV4.Repo
  end

  graphql do
    type :pos_pos_order_line

    mutations do
      create :create_pos_pos_order_line, :create
      update :update_pos_pos_order_line, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_name, :string do
      allow_nil? false
      public? true
    end
    attribute :product_code, :string, public?: true
    attribute :quantity, :decimal do
      allow_nil? false
      public? true
    end
    attribute :unit_price, :decimal do
      allow_nil? false
      public? true
    end
    attribute :discount, :decimal do
      default 0
      public? true
    end
    attribute :price_subtotal, :decimal, public?: true
    attribute :price_subtotal_incl, :decimal, public?: true
    attribute :tax_ids, :string, public?: true
    attribute :cost_price, :decimal, public?: true
    attribute :margin, :decimal, public?: true
    attribute :margin_percent, :decimal, public?: true
    attribute :note, :string, public?: true
    attribute :lot_name, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :order, UniboV4.POS.PosOrder do
      public? true
      allow_nil? false
    end
    belongs_to :product, UniboV4.POS.Product do
      public? true
      allow_nil? false
    end
    belongs_to :refunded_orderline, UniboV4.POS.PosOrderLine do
      public? true
    end
    has_many :refund_orderlines, UniboV4.POS.PosOrderLine do
      public? true
      destination_attribute :refunded_orderline_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:product_name, :product_code, :quantity, :unit_price, :discount, :tax_ids, :cost_price, :note, :lot_name]
      argument :order_id, :uuid, allow_nil?: false
      change manage_relationship(:order_id, :order, type: :append, on_lookup: :relate)
      argument :product_id, :uuid, allow_nil?: false
      change manage_relationship(:product_id, :product, type: :append, on_lookup: :relate)
      change fn changeset, _context ->
        quantity = Ash.Changeset.get_attribute(changeset, :quantity)
        unit_price = Ash.Changeset.get_attribute(changeset, :unit_price)
        discount = Ash.Changeset.get_attribute(changeset, :discount)

        if quantity && unit_price && discount do
          Ash.Changeset.force_change_attribute(changeset, :price_subtotal_incl, Decimal.mult(quantity, Decimal.mult(unit_price, Decimal.sub(1, Decimal.div(discount, 100)))))
        else
          changeset
        end
      end
      # TODO: 跨实体聚合表达式暂不支持
      # TODO: 跨实体聚合表达式暂不支持
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
      accept [:quantity, :unit_price, :discount]
      change fn changeset, _context ->
        quantity = Ash.Changeset.get_attribute(changeset, :quantity)
        unit_price = Ash.Changeset.get_attribute(changeset, :unit_price)
        discount = Ash.Changeset.get_attribute(changeset, :discount)

        if quantity && unit_price && discount do
          Ash.Changeset.force_change_attribute(changeset, :price_subtotal_incl, Decimal.mult(quantity, Decimal.mult(unit_price, Decimal.sub(1, Decimal.div(discount, 100)))))
        else
          changeset
        end
      end
      # TODO: 跨实体聚合表达式暂不支持
      # TODO: 跨实体聚合表达式暂不支持
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
    # TODO: 不支持的校验规则 custom
    validate compare(:unit_price, greater_than_or_equal_to: 0)
    validate compare(:discount, greater_than_or_equal_to: 0)
    validate compare(:discount, less_than_or_equal_to: 100)
    # TODO: 不支持的校验规则 custom
    # TODO: 不支持的校验规则 custom
    # TODO: 不支持的校验规则 custom
  end

end
