# Workflow: order_item_editing — 订单行编辑流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> [*]
# ```
defmodule UniboExPoc.Sales.SalesOrderItem do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Sales,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "销售订单明细（对齐 OFBiz OrderItem）"
  end

  postgres do
    table "sales_order_items"
    repo UniboExPoc.Repo
  end

  graphql do
    type :sales_sales_order_item

    mutations do
      create :create_sales_sales_order_item, :create
      update :update_sales_sales_order_item, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :order_item_type_id, :string do
      public? true
      description "行类型（对齐 OFBiz order_item_type_id，替代 Odoo display_type）"
    end
    attribute :seq_id, :integer do
      public? true
      description "行序号（对齐 OFBiz order_item_seq_id）"
    end
    attribute :item_description, :string do
      allow_nil? false
      public? true
      description "行描述（对齐 OFBiz item_description）"
    end
    attribute :quantity, :decimal do
      allow_nil? false
      default 1
      public? true
      description "订购数量（对齐 OFBiz quantity）"
    end
    attribute :cancel_quantity, :decimal do
      public? true
      description "取消数量（对齐 OFBiz cancel_quantity）"
    end
    attribute :unit_price, :decimal do
      allow_nil? false
      public? true
      description "成交单价（对齐 OFBiz unit_price）"
    end
    attribute :unit_list_price, :decimal do
      public? true
      description "目录/标牌价（对齐 OFBiz unit_list_price）"
    end
    attribute :discount_rate, :decimal do
      default 0
      public? true
      description "折扣率（对齐 OFBiz discount_rate，0-100）"
    end
    attribute :status_id, :string do
      public? true
      description "行状态（对齐 OFBiz status_id）"
    end
    attribute :estimated_delivery_date, :utc_datetime do
      public? true
      description "预计交货日（对齐 OFBiz estimated_delivery_date）"
    end
    attribute :comments, :string do
      public? true
      description "备注（对齐 OFBiz comments）"
    end
    attribute :is_promo, :boolean do
      default false
      public? true
      description "是否促销项（对齐 OFBiz is_promo）"
    end
    attribute :corresponding_po_id, :string do
      public? true
      description "对应采购单（对齐 OFBiz corresponding_po_id）"
    end
    attribute :product_name, :string do
      public? true
      description "产品名称（业务扩展）"
    end
    attribute :product_code, :string do
      public? true
      description "产品编码（业务扩展）"
    end
    attribute :qty_delivered, :decimal do
      default 0
      public? true
      description "已发货数量（业务扩展）"
    end
    attribute :qty_invoiced, :decimal do
      default 0
      public? true
      description "已开票数量（computed）"
    end
    attribute :price_subtotal, :decimal do
      public? true
      description "税前小计（computed）"
    end
    attribute :price_tax, :decimal do
      public? true
      description "税额（computed）"
    end
    attribute :price_total, :decimal do
      public? true
      description "含税合计（computed）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :qty_to_invoice, :decimal, expr(%{op: "case", branches: [%{when: %{op: "eq", args: [%{op: "ref", args: ["product", "invoice_policy"]}, "order"]}, then: %{op: "sub", args: [%{op: "ref", args: ["quantity"]}, %{op: "ref", args: ["qty_invoiced"]}]}}, %{when: %{op: "eq", args: [%{op: "ref", args: ["product", "invoice_policy"]}, "delivery"]}, then: %{op: "sub", args: [%{op: "ref", args: ["qty_delivered"]}, %{op: "ref", args: ["qty_invoiced"]}]}}]})
    calculate :invoice_status, :atom, expr(%{op: "case", branches: [%{when: %{op: "not_in", args: [%{op: "ref", args: ["order", "state"]}, ["sale", "done"]]}, then: "no"}, %{when: %{op: "gt", args: [%{op: "ref", args: ["qty_to_invoice"]}, 0]}, then: "to_invoice"}, %{when: %{op: "and", args: [%{op: "gt", args: [%{op: "ref", args: ["qty_delivered"]}, %{op: "ref", args: ["quantity"]}]}, %{op: "eq", args: [%{op: "ref", args: ["product", "invoice_policy"]}, "order"]}]}, then: "upselling"}, %{when: %{op: "gte", args: [%{op: "ref", args: ["qty_invoiced"]}, %{op: "ref", args: ["quantity"]}]}, then: "invoiced"}, %{otherwise: "no"}]})
  end

  relationships do
    belongs_to :order, UniboExPoc.Sales.SalesOrder do
      public? true
      allow_nil? false
    end
    belongs_to :product, UniboExPoc.Sales.Product do
      public? true
      allow_nil? false
    end
    many_to_many :tax_ids, UniboExPoc.Sales.Tax do
      public? true
      through UniboExPoc.Sales.SalesOrderItemTaxRel
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:item_description, :product_name, :product_code, :quantity, :unit_price, :discount_rate, :order_item_type_id, :seq_id, :estimated_delivery_date, :comments, :status_id, :is_promo]
      argument :order_id, :uuid, allow_nil?: false
      change manage_relationship(:order_id, :order, type: :append, on_lookup: :relate)
      argument :product_id, :uuid, allow_nil?: false
      change manage_relationship(:product_id, :product, type: :append, on_lookup: :relate)
      validate compare(:quantity, greater_than: 0)
      # message: "订购数量必须大于零"
      change UniboExPoc.Sales.Changes.SalesOrderItem.ComputePriceSubtotal
      change UniboExPoc.Sales.Changes.SalesOrderItem.ComputePriceTax
      change fn changeset, _context ->
        price_subtotal = Ash.Changeset.get_attribute(changeset, :price_subtotal)
        price_tax = Ash.Changeset.get_attribute(changeset, :price_tax)

        if price_subtotal && price_tax do
          Ash.Changeset.force_change_attribute(changeset, :price_total, (price_subtotal + price_tax))
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
      accept [:quantity, :unit_price, :discount_rate, :estimated_delivery_date, :comments, :status_id]
      # skipped: validate compare :quantity (incompatible with bulk update atomic path)
      # skipped: validate immutable :product (incompatible with bulk update atomic path)
      # skipped: validate immutable :unit_price (incompatible with bulk update atomic path)
      change UniboExPoc.Sales.Changes.SalesOrderItem.ComputePriceSubtotal
      change UniboExPoc.Sales.Changes.SalesOrderItem.ComputePriceTax
      change fn changeset, _context ->
        price_subtotal = Ash.Changeset.get_attribute(changeset, :price_subtotal)
        price_tax = Ash.Changeset.get_attribute(changeset, :price_tax)

        if price_subtotal && price_tax do
          Ash.Changeset.force_change_attribute(changeset, :price_total, (price_subtotal + price_tax))
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
    validate compare(:unit_price, greater_than_or_equal_to: 0)
    validate compare(:discount_rate, greater_than_or_equal_to: 0)
    validate compare(:discount_rate, less_than_or_equal_to: 100)
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
