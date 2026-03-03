# Workflow: order_item_editing — 订单行编辑流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> [*]
# ```
defmodule UniboV4.Sales.SalesOrderItem do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Sales,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "sales_order_items"
    repo UniboV4.Repo
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
    attribute :order_item_type_id, :string, public?: true
    attribute :seq_id, :integer, public?: true
    attribute :item_description, :string do
      allow_nil? false
      public? true
    end
    attribute :quantity, :decimal do
      allow_nil? false
      default 1
      public? true
    end
    attribute :cancel_quantity, :decimal, public?: true
    attribute :unit_price, :decimal do
      allow_nil? false
      public? true
    end
    attribute :unit_list_price, :decimal, public?: true
    attribute :discount_rate, :decimal do
      default 0
      public? true
    end
    attribute :status_id, :string, public?: true
    attribute :estimated_delivery_date, :utc_datetime, public?: true
    attribute :comments, :string, public?: true
    attribute :is_promo, :boolean do
      default false
      public? true
    end
    attribute :corresponding_po_id, :string, public?: true
    attribute :product_name, :string, public?: true
    attribute :product_code, :string, public?: true
    attribute :qty_delivered, :decimal do
      default 0
      public? true
    end
    attribute :qty_invoiced, :decimal do
      default 0
      public? true
    end
    attribute :price_subtotal, :decimal, public?: true
    attribute :price_tax, :decimal, public?: true
    attribute :price_total, :decimal, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :qty_to_invoice
    # TODO: 不支持的 calculation 表达式 :invoice_status
  end

  relationships do
    belongs_to :order, UniboV4.Sales.SalesOrder do
      public? true
      allow_nil? false
    end
    belongs_to :product, UniboV4.Sales.Product do
      public? true
      allow_nil? false
    end
    many_to_many :tax_ids, UniboV4.Sales.Tax do
      public? true
      through UniboV4.Sales.SalesOrderItemTaxRel
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
      # TODO: 跨实体聚合表达式暂不支持
      # TODO: 跨实体聚合表达式暂不支持
      change fn changeset, _context ->
        price_subtotal = Ash.Changeset.get_attribute(changeset, :price_subtotal)
        price_tax = Ash.Changeset.get_attribute(changeset, :price_tax)

        if price_subtotal && price_tax do
          Ash.Changeset.force_change_attribute(changeset, :price_total, Decimal.add(price_subtotal, price_tax))
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
      # TODO: 跨实体聚合表达式暂不支持
      # TODO: 跨实体聚合表达式暂不支持
      change fn changeset, _context ->
        price_subtotal = Ash.Changeset.get_attribute(changeset, :price_subtotal)
        price_tax = Ash.Changeset.get_attribute(changeset, :price_tax)

        if price_subtotal && price_tax do
          Ash.Changeset.force_change_attribute(changeset, :price_total, Decimal.add(price_subtotal, price_tax))
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

end
