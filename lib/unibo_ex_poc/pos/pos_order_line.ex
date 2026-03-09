# Workflow: orderline_management — 订单行管理（创建→修改）
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> update
# ```
defmodule UniboExPoc.POS.PosOrderLine do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.POS,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "POS 订单行，记录单个商品的销售明细"
  end

  postgres do
    table "pos_order_lines"
    repo UniboExPoc.Repo
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
      description "产品名称（快照）"
    end
    attribute :product_code, :string do
      public? true
      description "产品编码"
    end
    attribute :quantity, :decimal do
      allow_nil? false
      public? true
      description "数量（退款时为负）"
    end
    attribute :unit_price, :decimal do
      allow_nil? false
      public? true
      description "单价"
    end
    attribute :discount, :decimal do
      default 0
      public? true
      description "折扣百分比 (0-100)"
    end
    attribute :price_subtotal, :decimal do
      public? true
      description "不含税小计"
    end
    attribute :price_subtotal_incl, :decimal do
      public? true
      description "含税小计"
    end
    attribute :tax_ids, :string do
      public? true
      description "关联税率列表"
    end
    attribute :cost_price, :decimal do
      public? true
      description "成本价（用于毛利计算）"
    end
    attribute :margin, :decimal do
      public? true
      description "行毛利"
    end
    attribute :margin_percent, :decimal do
      public? true
      description "行毛利率"
    end
    attribute :note, :string do
      public? true
      description "服务员内部备注（餐饮模式）"
    end
    attribute :lot_name, :string do
      public? true
      description "批次/序列号"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :order, UniboExPoc.POS.PosOrder do
      public? true
      allow_nil? false
    end
    belongs_to :product, UniboExPoc.POS.Product do
      public? true
      allow_nil? false
    end
    belongs_to :refunded_orderline, UniboExPoc.POS.PosOrderLine do
      public? true
    end
    has_many :refund_orderlines, UniboExPoc.POS.PosOrderLine do
      public? true
      source_attribute :refunded_orderline_id
      destination_attribute :refunded_orderline_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:product_id, :product_name, :product_code, :quantity, :unit_price, :discount, :tax_ids, :cost_price, :note, :lot_name]
      argument :order_id, :uuid, allow_nil?: false
      change manage_relationship(:order_id, :order, type: :append, on_lookup: :relate)
      argument :product_id, :uuid, allow_nil?: false
      change manage_relationship(:product_id, :product, type: :append, on_lookup: :relate)
      change set_attribute(:price_subtotal_incl, expr((quantity * (unit_price * (1 - (discount / 100))))))
      change UniboExPoc.POS.Changes.PosOrderLine.ComputePriceSubtotal
      change UniboExPoc.POS.Changes.PosOrderLine.ComputeMargin
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:quantity, :unit_price, :discount]
      change set_attribute(:price_subtotal_incl, expr((quantity * (unit_price * (1 - (discount / 100))))))
      change UniboExPoc.POS.Changes.PosOrderLine.ComputePriceSubtotal
      change UniboExPoc.POS.Changes.PosOrderLine.ComputeMargin
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  validations do
    validate present(:quantity)
    validate compare(:unit_price, greater_than_or_equal_to: 0)
    validate compare(:discount, greater_than_or_equal_to: 0)
    validate compare(:discount, less_than_or_equal_to: 100)
    # validation: refund_line_link — 退款行必须关联原始订单行
    # validation: lot_tracking — 启用批次/序列号追踪的产品必须填写 lot_name
    # validation: computed_fields_readonly
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
